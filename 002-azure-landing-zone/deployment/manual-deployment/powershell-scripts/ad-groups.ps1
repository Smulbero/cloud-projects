# -------------------------------
# Core functions
# -------------------------------

# Create AD groups
function createAdGroups {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({
                foreach ($d in $_) {
                    if (!$d.displayName -or !$d.mailNickname) {
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
 
    textBlock -str "Creating ad groups.."
    
    foreach ($d in $data) {
        # Check if group already exists
        $existing_group = getAdGroupInfo -display_name $d.displayName
        if ($existing_group.id) {
            operationOutput -operation "SKIPPED" -message "AD group '$($d.displayName)' already exists"
            $skipped++
            continue
        }

        # Try to create new ad group
        az ad group create `
            --display-name $d.displayName `
            --mail-nickname $d.mailNickname `
            --output none 2>&1 | Tee-Object -FilePath "logs/ad-group-create-error.log" -Append | Out-Null

        if ($LASTEXITCODE -ne 0) {
            operationOutput -operation "FAILED" -message "Failed to create AD group: $($d.displayName)"
            $failed++
        }
        else {
            operationOutput -operation "SUCCEED" -message "Created AD group: $($d.displayName)"
            $created++
        }
    }
  
    textBlock -str "..ad groups created"
    textBlock -str "Summary"
    operationOutput -operation "SUCCEED" -message "Created: $created"     
    operationOutput -operation "SKIPPED" -message "Skipped: $skipped"     
    operationOutput -operation "FAILED" -message "Failed: $failed`n" 
}

# Delete AD groups
function deleteAdGroups {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({
                foreach ($d in $_) {
                    if (!$d.displayName) {
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

    if ($confirmation -eq "n") {
        Write-Host "Aborting AD group deletion"
        return
    }

    textBlock -str "Deleting ad groups.."

    foreach ($d in $data) {

        # Check if group exists
        $existing_group = getAdGroupInfo -display_name $d.displayName
        if (!$existing_group.id) {
            operationOutput -operation "SKIPPED" -message "AD group '$($d.displayName)' doesn't exist"
            $skipped++
            continue
        }

        # Try to delete the ad group
        az ad group delete `
            --group $existing_group.id `
            --output none 2>&1 | Tee-Object -FilePath "logs/ad-group-delete-error.log" -Append | Out-Null

        if ($LASTEXITCODE -ne 0) {
            operationOutput -operation "FAILED" -message "Failed to delete AD group: $($d.displayName)"
            $failed++
        }
        else {
            operationOutput -operation "SUCCEED" -message "Deleted AD group: $($d.displayName)"
            $deleted++
        }
    }

    textBlock -str "..ad groups deleted"
    textBlock -str "Summary"
    operationOutput -operation "SUCCEED" -message "Deleted: $deleted"     
    operationOutput -operation "SKIPPED" -message "Skipped: $skipped"     
    operationOutput -operation "FAILED" -message "Failed: $failed`n"   
}

# Function for permission assignments?
function assignPermissions {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({
                foreach ($d in $_) {
                    if (!$d.permission_assignments -or !$d.permission_assignments.scope -or !$d.permission_assignments.permissions) {
                        throw "Given data must contain following properties: object 'permission_assignments' with properties 'scope', 'permissions'"
                    }
                }
                return $true
            })]
        $data
    )    

    $assigned = 0
    $skipped = 0
    $failed = 0

    textBlock -str "Assigning permissions to ad groups.."
    
    foreach ($d in $data) {
        $ad_group = getAdGroupInfo -display_name $d.displayName

        if(!$ad_group) {
            operationOutput -operation "SKIPPED" -message "AD group '$($d.displayName)' doesn't exist"
            $skipped++
            continue
        }

        # Build scope string
        $scope = getScopeInfo -str $d.permission_assignments.scope
        foreach ($permission in $d.permission_assignments.permissions) {
            # Try to assing role to the scope
            az role assignment create `
                --role $permission `
                --scope $scope `
                --assignee $ad_group.id `
                --output none 2>&1 | Tee-Object -FilePath "logs/ag-permission-tbd.log" -Append | Out-Null

            if ($LASTEXITCODE -ne 0) {
                operationOutput -operation "FAILED" -message "Failed to assign permissions to ad group: $($ad_group.displayName)"
                $failed++
            }
            else {
                operationOutput -operation "SUCCEED" -message "Assigned permission '$permission' to ad group '$($ad_group.displayName)' on scope '$($d.permission_assignments.scope)'"
                $assigned++
            }
        }
    }

    textBlock -str "..permissions assigned"
    textBlock -str "Summary"
    operationOutput -operation "SUCCEED" -message "Assigned: $assigned"     
    operationOutput -operation "SKIPPED" -message "Skipped: $skipped"     
    operationOutput -operation "FAILED" -message "Failed: $failed`n"   
}

