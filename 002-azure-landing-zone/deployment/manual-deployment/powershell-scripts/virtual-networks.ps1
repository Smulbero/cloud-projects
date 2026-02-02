# -------------------------------
# Core functions
# -------------------------------

# Create virtual networks
function createVirtualNetworks {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({
                foreach ($d in $_) {
                    if (!$d.name -or !$d.tags) {
                        throw "Given data must contain following properties: 'name', 'tags'"
                    }
                }
                return $true
            })]
        $data
    )

    $created = 0
    $skipped = 0
    $failed = 0    

    Write-Host "# --------------------"
    Write-Host "# Creating virtual networks.."
    Write-Host "# --------------------"
    foreach ($d in $data) {
        # Check if resource exists
        $existing_resource = (getNetworkInfo -name $d.name)
        if ($existing_resource.id) {
            operationOutput -operation "SKIPPED" -message "Virtual network '$($existing_resource.name)' already exists"
            $skipped++
            continue
        }

        # Check if resource group for vnet exists
        $resource_group = getResourceGroupInfo -name $d.name
        if (!$resource_group.id) {
            operationOutput -operation "SKIPPED" -message "Resource group for '$($d.name)' not found"
            $skipped++
            continue
        }

        $network_name = "$VNET_PREFIX-$($d.name)-$($resource_group.location)"

        if ($d.tags -and $d.tags.Count -gt 0) {
            # Create key=value tag pairs
            $tagsParam = @(
                $d.tags.GetEnumerator() | ForEach-Object { $_.Key, $_.Value -join '=' }
            )
            
            # Try to create new vnet
            az network vnet create `
                --name $network_name `
                --resource-group $resource_group.name `
                --address-prefix $d.address_prefix `
                --tags $tagsParam `
                --no-wait `
                --output none 2>&1 | Tee-Object -FilePath "logs/vnet-create-error.log" -Append | Out-Null
        }
        else {
            # Try to create new vnet without tags
            az network vnet create `
                --name $network_name `
                --resource-group $resource_group.name `
                --address-prefix $d.address_prefix `
                --output none 2>&1 | Tee-Object -FilePath "logs/vnet-create-error.log" -Append | Out-Null
        }

        if ($LASTEXITCODE -ne 0) {
            operationOutput -operation "FAILED" -message "Failed to create virtual network: $network_name"
            $failed++
        }
        else {
            operationOutput -operation "SUCCEED" -message "Created virtual network: $network_name"
            $created++
        }
    }
    Write-Host "# --------------------"
    Write-Host "# ..virtual networks created"
    Write-Host "# --------------------`n"
    Write-Host "# --------------------"
    Write-Host "# Summary"
    Write-Host "# --------------------"    
    Write-Host "Created: $created"    
    Write-Host "Skipped: $skipped"    
    Write-Host "Failed: $failed`n"    
}

# Delete virtual networks
function deleteVirtualNetworks {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({
                foreach ($d in $_) {
                    if (!$d.name) {
                        throw "Given data must contain following properties: 'name'"
                    }
                }
                return $true
            })]
        $data
    )

    $deleted = 0
    $skipped = 0
    $failed = 0   

    $confirmation = (Read-Host "Delete given virtual networks? (y/n)").ToLower()

    if ($confirmation -eq "n") {
        Write-Host "Aborting virtual network deletion"
        return
    }
    Write-Host "# --------------------"
    Write-Host "# Deleting virtual networks.."
    Write-Host "# --------------------"
    foreach ($d in $data) {
        # Check if resource exists
        $existing_resource = (getNetworkInfo -name $d.name)       
        if (!$existing_resource.id) {
            operationOutput -operation "SKIPPED" -message "Virtual network '$($d.name)' doesn't exist"
            $skipped++
            continue
        }

        # Try to delete resource
        az network vnet delete `
            --resource-group $existing_resource.resourceGroup `
            --name $existing_resource.name `
            --no-wait `
            --output none 2>&1 | Tee-Object -FilePath "logs/vnet-delete-error.log" -Append | Out-Null

        if ($LASTEXITCODE -ne 0) {
            operationOutput -operation "FAILED" -message "Failed to delete virtual network: $($existing_resource.name)"
            $failed++
        }
        else {
            operationOutput -operation "SUCCEED" -message "Deleted virtual network: $($existing_resource.name)"
            $deleted++
        }
    }
    Write-Host "# --------------------"
    Write-Host "# ..virtual networks deleted"
    Write-Host "# --------------------`n"
    Write-Host "# --------------------"
    Write-Host "# Summary"
    Write-Host "# --------------------"    
    Write-Host "Deleted: $deleted"    
    Write-Host "Skipped: $skipped"    
    Write-Host "Failed: $failed`n"    
}

# Create network peerings
function createHubAndSpoke {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({
                foreach ($d in $_) {
                    if (!$d.name -or !$d.network) {
                        throw "Given data must contain following properties: 'name', 'network"
                    }
                }
                return $true
            })]
        $data
    )

    $created = 0
    $failed = 0
    $skipped = 0

    $hub_network = $null
    $spoke_network = $null

    Write-Host "# --------------------"
    Write-Host "# Peering vnets.."
    Write-Host "# --------------------"

    # Get a vnet with hub assignment, break the loop on first match
    foreach ($d in $data) {
        if ($d.network.ToLower() -eq "hub") {
            $hub_network = getNetworkInfo -name $d.name
            break
        }
        else {
            operationOutput -operation "FAILED" -message "Network for hub assignment not found, exiting"
            return
        }
    }

    # Create peerings
    foreach ($d in $data) {
        # Find spoke networks from data
        if ($d.network.ToLower() -eq "hub" -or $d.network -eq "") {
            continue
        }        

        $spoke_network = getNetworkInfo -name $d.name
        # Check if spoke network exists
        if(!$spoke_network.id) {
            operationOutput -operation "SKIPPED" -message "Spoke network for '$($d.name)' not found"
            $skipped++
            continue
        }

        # Create peering from hub to spoke
        $peering_name = "$($hub_network.name)-$($spoke_network.name)"

        az network vnet peering create `
            --name $peering_name `
            --resource-group $hub_network.resourceGroup `
            --vnet-name $hub_network.name `
            --remote-vnet $spoke_network.id `
            --allow-forwarded-traffic true `
            --allow-vnet-access true `
            --no-wait `
            --output none 2>&1 | Tee-Object -FilePath "logs/peering-error.log" -Append | Out-Null

        if ($LASTEXITCODE -ne 0) {
            operationOutput -operation "FAILED" -message "Failed to create a vnet peering from '$($hub_network.name)' to '$($spoke_network.name)'"
            $failed++
            continue
        }
        else {
            operationOutput -operation "SUCCEED" -message "Created a vnet peering from '$($hub_network.name)' to '$($spoke_network.name)'"

            # Create peering from spoke to hub
            $peering_name = "$($spoke_network.name)-$($hub_network.name)"

            az network vnet peering create `
            --name $peering_name `
            --resource-group $spoke_network.resourceGroup `
            --vnet-name $spoke_network.name `
            --remote-vnet $hub_network.id `
            --allow-forwarded-traffic true `
            --allow-vnet-access true `
            --no-wait `
            --output none 2>&1 | Tee-Object -FilePath "logs/peering-error.log" -Append | Out-Null

            if ($LASTEXITCODE -ne 0) {
                operationOutput -operation "FAILED" -message "Failed to create a vnet peering from '$($spoke_network.name)' to '$($hub_network.name)'"
                $failed++
                continue
            }
            else {
                operationOutput -operation "SUCCEED" -message "Created a vnet peering from '$($spoke_network.name)' to '$($hub_network.name)'"
                $created++
            }
        }
    }

    Write-Host "# --------------------"
    Write-Host "# ..vnet peering done"
    Write-Host "# --------------------`n"
    Write-Host "# --------------------"
    Write-Host "# Summary"
    Write-Host "# --------------------"    
    Write-Host "Created: $created"    
    Write-Host "Skipped: $skipped"    
    Write-Host "Failed: $failed`n" 
}
