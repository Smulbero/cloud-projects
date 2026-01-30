$AD_GROUPS = @( 
    @{ 
        displayName = "Platform Admins"
        mailNickname = "PlatformAdmins"
        permissions = "Owner"
    },
    @{ 
        displayName = "Platform readers"
        mailNickname = "PlatformReaders"
        permissions = "Reader"
    },
    @{ 
        displayName = "Identity admins"
        mailNickname = "IdentityAdmins"
        permissions = @("Contributor", "Reader")
    },
    @{ 
        displayName = "Identity contributors"         
        mailNickname = "IdentityContributors"        
        permissions = "Contributor"
    },
    @{ 
        displayName = "Identity operators"            
        mailNickname = "IdentityOperators"           
        permissions = @("Managed Identity Operator", "Reader")
    },
    @{ 
        displayName = "Management admins"             
        mailNickname = "ManagementAdmins"            
        permissions = @("Contributor", "Reader")
    },
    @{ 
        displayName = "Management contributors"       
        mailNickname = "ManagementContributors"      
        permissions = "Contributor"
    },
    @{ 
        displayName = "Connectivity admins"           
        mailNickname = "ConnectivityAdmins"          
        permissions = @("Contributor", "Reader")
    },
    @{ 
        displayName = "Connectivity contributors"     
        mailNickname = "ConnectivityContributors"    
        permissions = "Network Contributor"
    },
    @{ 
        displayName = "Security admins"               
        mailNickname = "SecurityAdmins"              
        permissions = @("Contributor", "Reader")
    },
    @{ 
        displayName = "Security contributors"         
        mailNickname = "SecurityContributors"      
        permissions = "Contributor"
    },
    @{ 
        displayName = "Security operators"            
        mailNickname = "SecurityOperators"           
        permissions = "Security Admin"
    }
)

# Create AD groups
function createAdGroups {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            foreach ($d in $_) {
                if(!$d.displayName -or !$d.mailNickname -or !$d.permissions) {
                    throw "Given data must contain following properties: 'displayName', 'mailNickname', 'permissions'"
                }
            }
            return $true
        })]
        $data
    )

    $created = 0
    $skipped = 0
    $failed = 0

    Write-Output "## Creating groups.. ##"    
    foreach ($d in $data) {
        # Check if group already exists
        $existingGroup = az ad group list --filter "MailNickname eq '$($d.mailNickname)'" --query "[0].id" -o tsv

        if ($existingGroup) {
            Write-Output "[SKIPPED] Group with mail nickname '$($d.displayName)' already exists"
            $skipped++
            continue
        }

        # Create the group
        az ad group create `
            --display-name $d.displayName `
            --mail-nickname $d.mailNickname `
            -o none

        if ($LASTEXITCODE -ne 0) {
            Write-Output "[FAILED] Failed to create group: $($d.displayName)"
            $failed++
        } else {
            Write-Output "[SUCCESS] Created group: $($d.displayName)"
            $created++
        }
    }
    Write-Output "## groups created. ##"
    Write-Output "Summary"    
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
                if(!$d.displayName -or !$d.mailNickname -or !$d.permissions) {
                    throw "Given data must contain following properties: 'displayName', 'mailNickname', 'permissions'"
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

    Write-Output "## Deleting groups.. ##"
    
    foreach($d in $data) {
        # Check if group exists
        $existingGroup = az ad group list --filter "DisplayName eq '$($d.displayName)'" --query "[0].id" -o tsv

        if (!$existingGroup) {
            Write-Output "[SKIPPED] Group '$($d.displayName)' doesn't exists"
            $skipped++
            continue
        }

        # Delete the group
        az ad group delete `
            --group $existingGroup `
            -o none

        if ($LASTEXITCODE -ne 0) {
            Write-Output "[FAILED] Failed to delete group: $($d.displayName)"
            $failed++
        } else {
            Write-Output "[SUCCESS] Deleted group: $($d.displayName)"
            $deleted++
        }
    }

    Write-Output "## groups deleted. ##"
    Write-Output "Summary"    
    Write-Output "Deleted: $deleted"    
    Write-Output "Skipped: $skipped"    
    Write-Output "Failed: $failed"
}