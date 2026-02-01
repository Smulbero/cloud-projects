
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
        "SKIPPED_FOUND"         { Write-Output "[SKIPPED] AD group '$resource' already exists" }
        "SKIPPED_NOT_FOUND"     { Write-Output "[SKIPPED] AD group '$resource' doesn't exists" }
        "CREATE_FAILED"         { Write-Output "[FAILED] Failed to create ad group: $resource" }
        "DELETE_FAILED"         { Write-Output "[FAILED] Failed to delete ad group: $resource" }
        "CREATE_SUCCEED"        { Write-Output "[SUCCESS] Created ad group: $resource" }
        "DELETE_SUCCEED"        { Write-Output "[SUCCESS] Deleted ad group: $resource" }
    }    
}

# -------------------------------
# Helper funtions end
# -------------------------------

# Create AD groups
function createAdGroups {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            foreach ($d in $_) {
                if(!$d.displayName -or !$d.mailNickname) {
                    throw "Given data must contain following properties: 'displayName', 'mailNickname'"
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
    Write-Output "# Creating ad groups.."
    Write-Output "# --------------------"   
    foreach ($d in $data) {
        # Check if group already exists
        $existingGroup = az ad group list --filter "MailNickname eq '$($d.mailNickname)'" --query "[0].id" -o tsv

        if ($existingGroup) {
            operationOutput -operation "SKIPPED_FOUND" -resource $d.displayName
            $skipped++
            continue
        }

        # Create the group
        az ad group create `
            --display-name $d.displayName `
            --mail-nickname $d.mailNickname `
            --output none 2>&1 | Tee-Object -FilePath "logs/ad-group-create-error.log" -Append | Out-Null

        if ($LASTEXITCODE -ne 0) {
            operationOutput -operation "CREATE_FAILED" -resource $d.displayName
            $failed++
        } else {
            operationOutput -operation "CREATE_SUCCEED" -resource $d.displayName
            $created++
        }
    }
    Write-Output "# --------------------"
    Write-Output "# ..ad groups created"
    Write-Output "# --------------------"
    Write-Output ""
    Write-Output "# --------------------"
    Write-Output "# Summary"
    Write-Output "# --------------------"     
    Write-Output "Created: $created"    
    Write-Output "Skipped: $skipped"    
    Write-Output "Failed: $failed"    
}

# Delete AD groups
function deleteAdGroups {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            foreach ($d in $_) {
                if(!$d.displayName) {
                    throw "Given data must contain following properties: 'displayName'"
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
        Write-Output "Aborting AD group deletion"
        return
    }

    Write-Output "# --------------------"
    Write-Output "# Deleting ad groups.."
    Write-Output "# --------------------"
    
    foreach($d in $data) {

        # Check if group exists
        $existingGroup = az ad group list --filter "DisplayName eq '$($d.displayName)'" --query "[0].id" -o tsv

        if (!$existingGroup) {
            operationOutput -operation "SKIPPED_NOT_FOUND" -resource $d.displayName
            $skipped++
            continue
        }

        # Delete the group
        az ad group delete `
            --group $existingGroup `
            --output none 2>&1 | Tee-Object -FilePath "logs/ad-group-delete-error.log" -Append | Out-Null

        if ($LASTEXITCODE -ne 0) {
            operationOutput -operation "DELETE_FAILED" -resource $d.displayName
            $failed++
        } else {
            operationOutput -operation "DELETE_SUCCEED" -resource $d.displayName
            $deleted++
        }
    }

    Write-Output "# --------------------"
    Write-Output "# ..ad groups deleted"
    Write-Output "# --------------------" 
    Write-Output ""
    Write-Output "# --------------------"
    Write-Output "# Summary"
    Write-Output "# --------------------"     
    Write-Output "Deleted: $deleted"    
    Write-Output "Skipped: $skipped"    
    Write-Output "Failed: $failed"
}

# Function for permission assignments?