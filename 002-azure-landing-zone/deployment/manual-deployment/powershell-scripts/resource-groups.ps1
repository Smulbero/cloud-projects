# -------------------------------
# Core functions
# -------------------------------

# Create resource groups
function createResourceGroups {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            foreach ($d in $_) {
                if(!$d.name -or !$d.location -or !$d.tags) {
                    throw "Given data must contain following properties: 'name', 'location', 'tags'"
                }
            }
            return $true
        })]
        $data
    )

    $created = 0
    $skipped = 0
    $failed = 0    

    textBlock -message "Creating resource groups.."

    foreach($d in $data) {
        
        # Check if resource already exists
        $existing_resource = getResourceGroupInfo -name $d.name
        if($existing_resource.id) {
            operationOutput -operation "SKIPPED" -message "Resource group '$($existing_resource.name)' already exists"            
            $skipped++
            continue
        }

        $resource_name = "$($RESOURCE_GROUP_PREFIX)-$($d.name)-$($d.location)"

        if($d.tags -and $d.tags.Count -gt 0) {
            # Create key=value tag pairs
            $tagsParam = @(
                $d.tags.GetEnumerator() | ForEach-Object { $_.Key, $_.Value -join '=' }
            )
    
            az group create `
                --name $resource_name `
                --location $d.location `
                --tags $tagsParam `
                --output none 2>&1 | Tee-Object -FilePath "logs/rg-create-error.log" -Append | Out-Null
        } else {
            # Attempt to create resource without tags
            # Shouldn't happen in this project since required tags are enforced
            az group create `
                --name $resource_name `
                --location $d.location `
                --output none 2>&1 | Tee-Object -FilePath "logs/rg-create-error.log" -Append | Out-Null
        }

        if($LASTEXITCODE -ne 0) {
           operationOutput -operation "FAILED" -message "Failed to create resource group: $resource_name" 
            $failed++
        } else {
            operationOutput -operation "SUCCEED" -message "Created resource group: $resource_name" 
            $created++
        }
    }

    textBlock -message "..resource groups created"
    summaryBlock -printOuts @(
        @{
            operation = "SUCCEED"
            message = "Created: $created"
        }
        @{
            operation = "SKIPPED"
            message = "Skipped: $skipped"
        }
        @{
            operation = "FAILED"
            message = "Failed: $failed"
        }
    )  
}

# Delete resource groups
function deleteResourceGroups {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            foreach ($d in $_) {
                if(!$d.name -or !$d.location) {
                    throw "Given data must contain following properties: 'name', 'location'"
                }
            }
            return $true
        })]
        $data
    )

    $deleted = 0
    $skipped = 0
    $failed = 0   

    $confirmation = (Read-Host "Delete given resource groups? (y/n)").ToLower()

    if($confirmation -eq "n") {
        Write-Host "Aborting resource group deletion"
        return
    }

    textBlock -message "Deleting resource groups.."

    foreach($d in $data) {
        # Check if resource exists
        $existing_resource = getResourceGroupInfo -name $d.name
        if(!$existing_resource.id) {
            $resource = "$RESOURCE_GROUP_PREFIX-$($d.name)-$($d.location)"
            operationOutput -operation "SKIPPED" -message "Resource group '$resource' doesn't exist"          
            $skipped++
            continue
        }        
        
        # Try to delete resource
        az group delete `
            --name $existing_resource.name `
            --no-wait `
            --yes `
            --output none 2>&1 | Tee-Object -FilePath "logs/rg-delete-error.log" -Append | Out-Null

        if($LASTEXITCODE -ne 0) {
            operationOutput -operation "FAILED" -message "Failed to delete resource group: $($existing_resource.name)" 
            $failed++
        } else {
            operationOutput -operation "SUCCEED" -message "Deleted resource group: $($existing_resource.name)"  
            $deleted++
        }
    }

    textBlock -message "..resource groups deleted"
    summaryBlock -printOuts @(
        @{
            operation = "SUCCEED"
            message = "Deleted: $deleted"
        }
        @{
            operation = "SKIPPED"
            message = "Skipped: $skipped"
        }
        @{
            operation = "FAILED"
            message = "Failed: $failed"
        }
    )  
}
