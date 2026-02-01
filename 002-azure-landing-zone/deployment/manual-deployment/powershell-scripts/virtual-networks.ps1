$RESOURCE_VNET_PREFIX = "vnet"

# -------------------------------
# Helper funtions start
# -------------------------------

function operationOutput {
    param ( 
        [Parameter(Mandatory = $true)]
        $operation,
        $resource
    )
    switch ($operation) {
        "SKIPPED_FOUND" { Write-Output "[SKIPPED] Virtual network '$resource' already exists" }
        "SKIPPED_NOT_FOUND" { Write-Output "[SKIPPED] Virtual network '$resource' doesn't exists" }
        "CREATE_FAILED" { Write-Output "[FAILED] Failed to create virtual network: $resource" }
        "DELETE_FAILED" { Write-Output "[FAILED] Failed to delete virtual network: $resource" }
        "CREATE_SUCCEED" { Write-Output "$[SUCCESS] Created virtual network: $resource" }
        "DELETE_SUCCEED" { Write-Output "$[SUCCESS] Deleted virtual network: $resource" }
    }    
}

# Returns object with name and location attributes
function getResourceGroupInfo {
    param (
        [Parameter(Mandatory = $true)]
        $name
    )
        
    $resource_group = az group list --query "[?contains(name, '$($name)')]" | ConvertFrom-Json
        
    return $resource_group
}

# Return network name
function getHubNetworkInfo {
    param (
        [Parameter(Mandatory = $true)]
        $name
    )

    $hub_network_name = az network vnet list --query "[?contains(name, '$name')]" | ConvertFrom-Json

    return $hub_network_name
}

# Return network name
function getSpokeNetworkInfo {
    param (
        [Parameter(Mandatory = $true)]
        $name
    )
    
    $spoke_network_name = az network vnet list --query "[?contains(name, '$name')]" | ConvertFrom-Json

    return $spoke_network_name
}

# -------------------------------
# Helper funtions end
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

    Write-Output "## Creating virtual networks.. ##"
    foreach ($d in $data) {
        $resource_group = getResourceGroupInfo -name $d.name
        $resource_name = "$($RESOURCE_VNET_PREFIX)-$($d.name)-$($resource_group.location)"

        # Check if resource already exists
        az network vnet show `
            --name $resource_name `
            --resource-group $resource_group.name `
            -o none 2$null

        if ($LASTEXITCODE -eq 0) {
            operationOutput -operation "SKIPPED_FOUND" -resource $resource_name
            $skipped++
            continue
        }

        if ($d.tags -and $d.tags.Count -gt 0) {
            # Create key=value tag pairs
            $tagsParam = @(
                $d.tags.GetEnumerator() |  Tee-Object -filepath ForEach-Object { $_.Key, $_.Value -join '=' }
            )
    
            az network vnet create `
                --name $resource_name `
                --resource-group $resource_group.name `
                --tags $tagsParam `
                --no-wait `
                --output none 2>&1 | Tee-Object -FilePath "logs/vnet-create-error" -Append | Out-Null
        }
        else {
            # Attempt to create resource without tags
            # Shouldn't happen in this project since required tags are enforced
            az network vnet create `
                --name $resource_name `
                --resource-group $resource_group.name `
                --output none 2>&1 | Tee-Object -FilePath "logs/vnet-create-error" -Append | Out-Null
        }

        if ($LASTEXITCODE -ne 0) {
            operationOutput -operation "CREATE_FAILED" -resource $resource_name
            $failed++
        }
        else {
            operationOutput -operation "CREATE_SUCCEED" -resource $resource_name
            $created++
        }
    }
    Write-Output "## virtual networks created. ##"
    Write-Output "Summary"    
    Write-Output "Created: $created"    
    Write-Output "Skipped: $skipped"    
    Write-Output "Failed: $failed"    
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
        Write-Output "Aborting virtual network deletion"
        return
    }

    Write-Output "## Creating virtual networks.. ##"
    foreach ($d in $data) {
        $resource_group = az group list --query "[?contains(name, '$($d.name)')].{name:name, location:location}" |  Tee-Object -filepath ConvertFrom-Json
        $resource_name = "$($RESOURCE_VNET_PREFIX)-$($d.name)-$($resource_group.location)"
        
        # Check if resource exists
        az network vnet show `
            --name $resource_name `
            --resource-group $resource_group.name `
            --output none 2$null

        if ($LASTEXITCODE -ne 0) {
            operationOutput -operation "SKIPPED_NOT_FOUND" -resource $resource_name
            $skipped++
            continue
        }

        az network vnet delete `
            --resource-group $resource_group.name `
            --name $resource_name `
            --no-wait `
            --yes `
            --output none 2>&1 | Tee-Object -FilePath "logs/vnet-delete-error" -Append | Out-Null

        if ($LASTEXITCODE -ne 0) {
            operationOutput -operation "DELETE_FAILED" -resource $resource_name
            $failed++
        }
        else {
            operationOutput -operation "DELETE_SUCCEED" -resource $resource_name
            $deleted++
        }
    }
    Write-Output "## resource groups deleted. ##"
    Write-Output "Summary"    
    Write-Output "Deleted: $deleted"    
    Write-Output "Skipped: $skipped"    
    Write-Output "Failed: $failed"    
}

# Create network peerings
# -------------------------------
# --remote-vnet would need a very specific value where to find the right resources
# could be done, but I rather not for this project
# -------------------------------
# function createHubAndSpoke {
#     param (
#         [Parameter(Mandatory = $true)]
#         [ValidateScript({
#                 foreach ($d in $_) {
#                     if (!$d.name -or !$d.network) {
#                         throw "Given data must contain following properties: 'name', 'network"
#                     }
#                 }
#                 return $true
#             })]
#         $data
#     )

#     $created = 0
#     $failed = 0

#     Write-Output "# --------------------"
#     Write-Output "# Peering vnets.."
#     Write-Output "# --------------------"

#     $hub_network_name = $null
#     $hub_resource_group = $null

#     # Get hub vnet name
#     foreach ($d in $data) {
#         if ($d.network.ToLower() -eq "hub") {
#             $hub_network = getHubNetworkInfo -name $d.name
#             $hub_network_name = $hub_network.name
#             $hub_resource_group = $hub_network.resourceGroup
#             break
#         }
#         else {
#             Write-Output "Network for hub assignment not found, exiting"
#             return
#         }
#     }

#     # Create peerings
#     foreach ($d in $data) {
#         if ($d.network.ToLower() -eq "hub" -or $d.network -eq "") {
#             continue
#         }        

#         # Create peering from hub to spoke
#         $spoke_network = getSpokeNetworkInfo -name $d.name
#         $spoke_network_name = $spoke_network.name
#         $peering_name = "$hub_network_name-$spoke_network_name"

#         az network vnet peering create `
#             --name $peering_name `
#             --resource-group $hub_resource_group `
#             --vnet-name $hub_network_name `
#             --remote-vnet $spoke_network_name `
#             --allow-forwarded-traffic true `
#             --allow-vnet-access true `
#             --no-wait `
#             --output none 2>&1 | Tee-Object -FilePath "logs/peering-error.log" -Append | Out-Null

#         if ($LASTEXITCODE -ne 0) {
#             Write-Output "[FAILED] Failed to create a vnet peering from '$hub_network_name' to '$spoke_network_name'"
#             $failed++
#             continue
#         }
#         else {
#             Write-Output "[SUCCEED] Created a vnet peering from '$hub_network_name' to '$spoke_network_name'"

#             # Create peering from spoke to hub
#             $peering_name = "$spoke_network_name-$hub_network_name"

#             az network vnet peering create `
#             --name $peering_name `
#             --resource-group $hub_resource_group `
#             --vnet-name $spoke_network_name `
#             --remote-vnet $hub_network_name `
#             --allow-forwarded-traffic true `
#             --allow-vnet-access true `
#             --no-wait `
#             --output none 2>&1 | Tee-Object -FilePath "logs/peering-error.log" -Append | Out-Null

#             if ($LASTEXITCODE -ne 0) {
#                 Write-Output "[FAILED] Failed to create a vnet peering from '$spoke_network_name' to '$hub_network_name'"
#                 $failed++
#                 continue
#             }
#             else {
#                 Write-Output "[SUCCEED] Created a vnet peering from '$spoke_network_name' to '$hub_network_name'"
#                 $created++
#             }
#         }
#     }

#     Write-Output "# --------------------"
#     Write-Output "# ..vnet peering done"
#     Write-Output "# --------------------"
#     Write-Output ""
#     Write-Output "# --------------------"
#     Write-Output "# Summary"
#     Write-Output "# --------------------"    
#     Write-Output "Created: $created"    
#     Write-Output "Failed: $failed" 
# }
