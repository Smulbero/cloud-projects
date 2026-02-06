# -------------------------------
# Helper functions
# -------------------------------
function operationOutput {
    param ( 
        [Parameter(Mandatory = $true)]
        $operation,
        $message
    )
    switch ($operation) {
        "SKIPPED"   { Write-Host "[SKIPPED] $message"     -ForegroundColor Yellow }
        "FAILED"    { Write-Host "[FAILED]  $message"     -ForegroundColor Red }
        "SUCCEED"   { Write-Host "[SUCCESS] $message"     -ForegroundColor Green }
    }    
}

function textBlock {
    param (
        $message
    )
    
    Write-Host "# ------------------------------"
    Write-Host "# $message"
    Write-Host "# ------------------------------"
    Write-Host ""
}

function summaryBlock {
    param (
        $printOuts
    )
    
    textBlock -message "Summary"

    foreach($printOut in $printOuts) {
        operationOutput -operation $printOut.operation -message $printOut.message
    }

    Write-Host ""
}

# Returns subscription object
function getSubscriptionInfo {
    $subscription = az account list --query "[?contains(name, 'Main')]" | ConvertFrom-Json
    return $subscription
}

# Build scope string for permission assignments
function getScopeInfo {
    param (
        [Parameter(Mandatory = $true)]
        $str
    )

    $scope = $null

    if ($str) {
        $subscription = getSubscriptionInfo
        $scope = "subscriptions/$($subscription.id)"
        if ($str -match "rg") {
            $resource_group = getResourceGroupInfo -name $str
            $scope += "/resourceGroups/$($resource_group.name)" 
            return $scope
        }

        return $scope
    }
}

# Returns ad group object
function getAdGroupInfo {
    param (
        [Parameter(Mandatory = $true)]
        $display_name
    )

    $ad_group = az ad group list --query "[?contains(displayName, '$display_name')]" | ConvertFrom-Json
        
    return $ad_group
}

# Returns resource group object
function getResourceGroupInfo {
    param (
        [Parameter(Mandatory = $true)]
        $name
    )
        
    $resource_group = az group list --query "[?contains(name, '$name')]" | ConvertFrom-Json
        
    return $resource_group
}

# Returns virtual network object
function getNetworkInfo {
    param (
        [Parameter(Mandatory = $true)]
        $name
    )

    $network = az network vnet list --query "[?contains(name, '$name')]" | ConvertFrom-Json

    return $network
}