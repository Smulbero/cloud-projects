$DEFAULT_LOCATION = "northeurope"
$DEFAULT_TAGS = @{
        CostCenter = "tbd"
        Owner = "tbd"
        DeployedMethod = "tbd"
        DeployedDate = "tbd"
    }
$RESOURCE_GROUP_PREFIX = "rg"
$VNET_PREFIX = "vnet"

$RESOURCE_GROUPS = @(
    @{
        name = "identity"
        location = $DEFAULT_LOCATION
        tags = @{
            CostCenter = "1234"
            Owner = "Test Owner"
            DeployedMethod = "Azure CLI"
            DeployedDate = ""
        }
    },
    @{
        name = "management"
        location = $DEFAULT_LOCATION
        tags = @{
            CostCenter = "1234"
            Owner = "Test Owner"
            DeployedMethod = ""
            DeployedDate = ""
        }
        
    },
    @{
        name = "connectivity"
        location = $DEFAULT_LOCATION
        tags = @{
            CostCenter = "54312"
            Owner = ""
            DeployedMethod = ""
            DeployedDate = ""
        }
    },
    @{
        name = "security"
        location = $DEFAULT_LOCATION
        tags = @{
            CostCenter = ""
            Owner = ""
            DeployedMethod = ""
            DeployedDate = ""
        }
    },
    @{
        name = "finance"
        location = $DEFAULT_LOCATION
        tags = @{
            CostCenter = ""
            Owner = ""
            DeployedMethod = ""
            DeployedDate = ""
        }
    }
    @{
        name = "testLocationPolicy"
        location = "eastus"
        tags = @{
            CostCenter = ""
            Owner = ""
            DeployedMethod = ""
            DeployedDate = ""
        }
    },
    @{
        name = "testTagsPolicy"
        location = $DEFAULT_LOCATION
        tags = @{
            CostCenter = ""
            Owner = ""
            DeployedDate = ""
        }
    }
    )
        
$VIRTUAL_NETWORKS = @(
        @{
        name = "connectivity"        
        address_prefix = "10.10.0.0/16"
        tags = @{
            CostCenter = "tbd"
            Owner = "tbd"
            DeployedMethod = "tbd"
            DeployedDate = "tbd"
        }
        network = "hub"
    }
    @{
        name = "identity"        
        address_prefix = "10.20.0.0/16"
        tags = @{
            CostCenter = "tbd"
            Owner = "tbd"
            DeployedMethod = "tbd"
            DeployedDate = "tbd"
        }
        network = "spoke"
    }
    @{
        name = "management"        
        address_prefix = "10.30.0.0/16"
        tags = @{
            CostCenter = "tbd"
            Owner = "tbd"
            DeployedMethod = "tbd"
            DeployedDate = "tbd"
        }
        network = "spoke"
    }
    @{
        name = "security"        
        address_prefix = "10.40.0.0/16"
        tags = @{
            CostCenter = "tbd"
            Owner = "tbd"
            DeployedMethod = "tbd"
            DeployedDate = "tbd"
        }
        network = "spoke"
    }
    @{
        name = "finance"        
        address_prefix = "10.50.0.0/16"
        tags = @{
            CostCenter = "tbd"
            Owner = "tbd"
            DeployedMethod = "tbd"
            DeployedDate = "tbd"
        }
        network = "spoke"
    }
    @{
        name = "testLocationPolicy"        
        address_prefix = "10.60.0.0/16"
        tags = @{
            CostCenter = "tbd"
            Owner = "tbd"
            DeployedMethod = "tbd"
            DeployedDate = "tbd"
        }
        network = "spoke"
    }
    @{
        name = "testTagsPolicy"        
        address_prefix = "10.70.0.0/16"
        tags = @{
            CostCenter = "tbd"
            Owner = "tbd"
            DeployedMethod = "tbd"
            DeployedDate = "tbd"
        }
        network = "spoke"
    }
)

$AD_GROUPS = @( 
    @{ 
        displayName = "Platform Admins"
        mailNickname = "PlatformAdmins"
        permission_assignments = @{
            scope = "subscription"
            permissions = "Owner"
        }
    },
    @{ 
        displayName = "Platform readers"
        mailNickname = "PlatformReaders"
        permission_assignments = @{
            scope = "subscription"
            permissions = "Reader"
        }        
    },
    @{ 
        displayName = "Identity admins"
        mailNickname = "IdentityAdmins"
        permission_assignments = @{
            scope = "rg-identity"
            permissions = @("Contributor", "Reader")
        }        
    },
    @{ 
        displayName = "Identity contributors"         
        mailNickname = "IdentityContributors"
        permission_assignments = @{
            scope = "rg-identity"
            permissions = "Contributor"
        }
    },
    @{ 
        displayName = "Identity operators"            
        mailNickname = "IdentityOperators"
        permission_assignments = @{
            scope = "rg-identity"
            permissions = @("Managed Identity Operator", "Reader")
        }
    },
    @{ 
        displayName = "Management admins"             
        mailNickname = "ManagementAdmins"
        permission_assignments = @{
            scope = "rg-management"
            permissions = @("Contributor", "Reader")
        }
    },
    @{ 
        displayName = "Management contributors"       
        mailNickname = "ManagementContributors"
        permission_assignments = @{
            scope = "rg-management"
            permissions = "Contributor"
        }
    },
    @{ 
        displayName = "Connectivity admins"           
        mailNickname = "ConnectivityAdmins"
        permission_assignments = @{
            scope = "rg-connectivity"
            permissions = @("Contributor", "Reader")
        }
    },
    @{ 
        displayName = "Connectivity contributors"     
        mailNickname = "ConnectivityContributors"
        permission_assignments = @{
            scope = "rg-connectivity"
            permissions = "Network Contributor"
        }
    },
    @{ 
        displayName = "Security admins"               
        mailNickname = "SecurityAdmins"
        permission_assignments = @{
            scope = "rg-security"
            permissions = @("Contributor", "Reader")
        }
    },
    @{ 
        displayName = "Security contributors"         
        mailNickname = "SecurityContributors"
        permission_assignments = @{
            scope = "rg-security"
            permissions = "Contributor"
        }
    },
    @{ 
        displayName = "Security operators"            
        mailNickname = "SecurityOperators"
        permission_assignments = @{
            scope = "rg-security"
            permissions = "Security Admin"
        }
    }
)