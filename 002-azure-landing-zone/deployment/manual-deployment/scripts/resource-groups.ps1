$DEFAULT_LOCATION = "northeurope"
$RESOURCE_PREFIX = "rg"
$RESOURCE_GROUPS = @(
    @{
        rgName = "identity"
        location = $DEFAULT_LOCATION
        tags = @{
            CostCenter = "1234"
            Owner = "Test Owner"
            DeployedMethod = "Azure CLI"
            DeployedDate = ""
        }
    },
    @{
        rgName = "management"
        location = $DEFAULT_LOCATION
        tags = @{
            CostCenter = "1234"
            Owner = "Test Owner"
            DeployedMethod = ""
            DeployedDate = ""
        }
        
    },
    @{
        rgName = "connectivity"
        location = $DEFAULT_LOCATION
        tags = @{
            CostCenter = "54312"
            Owner = ""
            DeployedMethod = ""
            DeployedDate = ""
        }
    },
    @{
        rgName = "security"
        location = $DEFAULT_LOCATION
        tags = @{
            CostCenter = ""
            Owner = ""
            DeployedMethod = ""
            DeployedDate = ""
        }
    },
    @{
        rgName = "finance"
        location = $DEFAULT_LOCATION
        tags = @{
            CostCenter = ""
            Owner = ""
            DeployedMethod = ""
            DeployedDate = ""
        }
    }
    @{
        rgName = "testLocationPolicy"
        location = "eastus"
        tags = @{
            CostCenter = ""
            Owner = ""
            DeployedMethod = ""
            DeployedDate = ""
        }
    },
    @{
        rgName = "testTagsPolicy"
        location = $DEFAULT_LOCATION
        tags = @{
            CostCenter = ""
            Owner = ""
            DeployedDate = ""
        }
    }
)

# Create resource groups
function createResourceGroups {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            foreach ($d in $_) {
                if(!$d.rgName -or !$d.location -or !$d.tags) {
                    throw "Given data must contain following properties: 'rgName', 'location', 'tags'"
                }
            }
            return $true
        })]
        $data
    )

    $created = 0
    $skipped = 0
    $failed = 0    

    Write-Output "## Creating resource groups.. ##"
    foreach($d in $data) {
        # Check if resource group already exists
        $existingRg = az group exists --name "$($RESOURCE_PREFIX)-$($d.rgName)-$($d.location)"

        if($existingRg -eq "true") {
            Write-Output "[SKIPPED] Resource group '$($RESOURCE_PREFIX)-$($d.rgName)-$($d.location)' already exists"
            $skipped++
            continue
        }

        if($d.tags -and $d.tags.Count -gt 0) {
            # Create key=value tag pairs
            $tagsParam = @(
                $d.tags.GetEnumerator() | ForEach-Object { $_.Key, $_.Value -join '=' }
            )
    
            az group create `
                --name "$($RESOURCE_PREFIX)-$($d.rgName)-$($d.location)" `
                --location $d.location `
                --tags $tagsParam `
                -o none
        } else {
            # Attempt to create resource without tags
            # Shouldn't happen in this project since required tags are enforced
            az group create `
                --name "$($RESOURCE_PREFIX)-$($d.rgName)-$($d.location)" `
                --location $d.location `
                -o none
        }

        if($LASTEXITCODE -ne 0) {
            Write-Output "[FAILED] Failed to create resource group: $($RESOURCE_PREFIX)-$($d.rgName)-$($d.location)"
            $failed++
        } else {
            Write-Output "[SUCCESS] Created resource group: $($RESOURCE_PREFIX)-$($d.rgName)-$($d.location)"
            $created++
        }
    }
    Write-Output "## resource groups created. ##"
    Write-Output "Summary"    
    Write-Output "Created: $created"    
    Write-Output "Skipped: $skipped"    
    Write-Output "Failed: $failed"    
}

# Delete resource groups
function deleteResourceGroups {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            foreach ($d in $_) {
                if(!$d.rgName -or !$d.location -or !$d.tags) {
                    throw "Given data must contain following properties: 'rgName', 'location', 'tags'"
                }
            }
            return $true
        })]
        $data
    )

    $deleted = 0
    $skipped = 0
    $failed = 0   

    $confirmation = (Read-Host "Delete given AD groups? (y/n)").ToLower()

    if($confirmation -eq "n") {
        Write-Output "Aborting resource group deletion"
        return
    }

    Write-Output "## Creating resource groups.. ##"
    foreach($d in $data) {
        # Check if resource group exists
        $existingRg = az group exists --name "$($RESOURCE_PREFIX)-$($d.rgName)-$($d.location)"

        if($existingRg -eq "false") {
            Write-Output "[SKIPPED] Resource group '"$($RESOURCE_PREFIX)-$($d.rgName)-$($d.location)"' doesn't exists"
            $skipped++
            continue
        }

        az group delete `
            --name "$($RESOURCE_PREFIX)-$($d.rgName)-$($d.location)" `
            --no-wait -y -o none

        if($LASTEXITCODE -ne 0) {
            Write-Output "[FAILED] Failed to delete resource group: $($RESOURCE_PREFIX)-$($d.rgName)-$($d.location)"
            $failed++
        } else {
            Write-Output "[SUCCESS] Deleted resource group: $($RESOURCE_PREFIX)-$($d.rgName)-$($d.location)"
            $deleted++
        }
    }
    Write-Output "## resource groups deleted. ##"
    Write-Output "Summary"    
    Write-Output "Deleted: $deleted"    
    Write-Output "Skipped: $skipped"    
    Write-Output "Failed: $failed"    
}