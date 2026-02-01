$RESOURCE_GROUP_PREFIX = "rg"

# -------------------------------
# Helper funtions start
# -------------------------------
function operationOutput {
    param ( 
        [Parameter(Mandatory=$true)]
        $operation,
        $resource
    )
    switch ($operation) {
        "SKIPPED_FOUND"         { Write-Output "[SKIPPED] Resource group '$resource' already exists" }
        "SKIPPED_NOT_FOUND"     { Write-Output "[SKIPPED] Resource group '$resource' doesn't exists" }
        "CREATE_FAILED"         { Write-Output "[FAILED] Failed to create resource group: $resource" }
        "DELETE_FAILED"         { Write-Output "[FAILED] Failed to delete resource group: $resource" }
        "CREATE_SUCCEED"        { Write-Output "[SUCCESS] Created resource group: $resource" }
        "DELETE_SUCCEED"        { Write-Output "[SUCCESS] Deleted resource group: $resource" }
    }    
}

# -------------------------------
# Helper funtions end
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

    Write-Output "# --------------------"
    Write-Output "# Creating resource groups.."
    Write-Output "# --------------------"
    foreach($d in $data) {
        $resource_name = "$($RESOURCE_GROUP_PREFIX)-$($d.name)-$($d.location)"

        # Check if resource already exists
        $existingRg = az group exists --name $resource_name

        if($existingRg -eq "true") {
            operationOutput -operation "SKIPPED_FOUND" -resource $resource_name            
            $skipped++
            continue
        }

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
            operationOutput -operation "CREATE_FAILED" -resource $resource_name
            $failed++
        } else {
            operationOutput -operation "CREATE_SUCCEED" -resource $resource_name
            $created++
        }
    }

    Write-Output "# --------------------"
    Write-Output "# ..resource groups created"
    Write-Output "# --------------------"
    Write-Output ""
    Write-Output "# --------------------"
    Write-Output "# Summary"
    Write-Output "# --------------------"    
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
        Write-Output "Aborting resource group deletion"
        return
    }

    Write-Output "# --------------------"
    Write-Output "# Deleting resource groups.."
    Write-Output "# --------------------"
    foreach($d in $data) {
        $resource_name = "$($RESOURCE_GROUP_PREFIX)-$($d.name)-$($d.location)"
        
        # Check if resource exists
        $existingRg = az group exists --name "$($RESOURCE_GROUP_PREFIX)-$($d.name)-$($d.location)"

        if($existingRg -eq "false") {
            operationOutput -operation "SKIPPED_NOT_FOUND" -resource $resource_name 
            $skipped++
            continue
        }
        
        # Try to delete resource
        az group delete `
            --name $resource_name `
            --no-wait `
            --yes `
            --output none 2>&1 | Tee-Object -FilePath "logs/rg-delete-error.log" -Append | Out-Null

        if($LASTEXITCODE -ne 0) {
            operationOutput -operation "DELETE_FAILED" -resource $resource_name
            $failed++
        } else {
            operationOutput -operation "DELETE_SUCCEED" -resource $resource_name
            $deleted++
        }
    }
    Write-Output "# --------------------"
    Write-Output "# ..resource groups deleted"
    Write-Output "# --------------------"
    Write-Output ""
    Write-Output "# --------------------"
    Write-Output "# Summary"
    Write-Output "# --------------------"    
    Write-Output "Deleted: $deleted"    
    Write-Output "Skipped: $skipped"    
    Write-Output "Failed: $failed"    
}
