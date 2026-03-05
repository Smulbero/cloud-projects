# -------------------------------------------------------------------------------------------------------
# Resource Groups
# -------------------------------------------------------------------------------------------------------
resource_groups = {
  identity = {
    location = "northeurope"
    tags = {
      CostCenter     = "12345"
      Owner          = "Joe Doe"
      DeployedMethod = "terraform"
      DeployedDate   = "Functions may not be called here."
    }
  }
  management = {
    location = "northeurope"
    tags = {
      CostCenter     = "23456"
      Owner          = "Joen Doen"
      DeployedMethod = "terraform"
      DeployedDate   = "Functions may not be called here."
    }
  }
  connectivity = {
    location = "northeurope"
    tags = {
      CostCenter     = "34567"
      Owner          = "Jae Doe"
      DeployedMethod = "terraform"
      DeployedDate   = "Functions may not be called here."
    }
  }
  security = {
    location = "northeurope"
    tags = {
      CostCenter     = "45678"
      Owner          = "Jaen Doen"
      DeployedMethod = "terraform"
      DeployedDate   = "Functions may not be called here."
    }
  }
  finance = {
    location = "northeurope"
    tags = {
      CostCenter     = "56789"
      Owner          = "Foo Bar"
      DeployedMethod = "terraform"
      DeployedDate   = "Functions may not be called here."
    }
  }
}

# -------------------------------------------------------------------------------------------------------
# Virtual Networks
# -------------------------------------------------------------------------------------------------------
virtual_networks = {
  identity = {
    network_address_space = ["10.10.0.0/20"]
    subnets = {
      DomainServicesSubnet = {
        subnet_name          = "DomainServicesSubnet"
        subnet_address_space = ["10.10.1.0/24"]
      }
      WorkloadSubnet = {
        subnet_name          = "WorkloadSubnet"
        subnet_address_space = ["10.10.2.0/24"]
      }
    }
    tags = {
      CostCenter     = "12345"
      Owner          = "Joe Doe"
      DeployedMethod = "terraform"
      DeployedDate   = "Functions may not be called here."
    }
  }
  management = {
    network_address_space = ["10.20.0.0/20"]
    tags = {
      CostCenter     = "23456"
      Owner          = "Joen Doen"
      DeployedMethod = "terraform"
      DeployedDate   = "Functions may not be called here."
    }
  }
  connectivity = {
    network_address_space = ["10.30.0.0/20"]
    subnets = {
      AzureBastionSubnet = {
        subnet_name          = "AzureBastionSubnet"
        subnet_address_space = ["10.30.1.0/24"]
      }
      AzureFirewallSubnet = {
        subnet_name          = "AzureFirewallSubnet"
        subnet_address_space = ["10.30.2.0/24"]
      }
    }
    tags = {
      CostCenter     = "34567"
      Owner          = "Jae Doe"
      DeployedMethod = "terraform"
      DeployedDate   = "Functions may not be called here."
    }
  }
  security = {
    network_address_space = ["10.40.0.0/20"]
    tags = {
      CostCenter     = "45678"
      Owner          = "Jaen Doen"
      DeployedMethod = "terraform"
      DeployedDate   = "Functions may not be called here."
    }
  }
  finance = {
    network_address_space = ["10.50.0.0/20"]
    subnets = {
      WorkloadSubnet = {
        subnet_address_space = ["10.50.1.0/24"]
      }
    }
    tags = {
      CostCenter     = "56789"
      Owner          = "Foo Bar"
      DeployedMethod = "terraform"
      DeployedDate   = "Functions may not be called here."
    }
  }
}

# -------------------------------------------------------------------------------------------------------
# AD groups
# -------------------------------------------------------------------------------------------------------
ad_groups = {
  platform_admins = {
    display_name = "Platform Admins"
    permission_assignments = {
      assignment_01 = {
        scope       = "subscription"
        permissions = ["Owner"]
      }
    }
  }
  platform_readers = {
    display_name = "Platform readers"
    permission_assignments = {
      assignment_01 = {
        scope       = "subscription"
        permissions = ["Reader"]
      }
    }
  }
  identity_admins = {
    display_name = "Identity Admins"
    permission_assignments = {
      assignment_01 = {
        scope       = "resourceGroup"
        scope_key   = "identity"
        permissions = ["Contributor", "Reader"]
      }
    }
  }
  management_contributors = {
    display_name = "Management contributors"
    permission_assignments = {
      assignment_01 = {
        scope       = "resourceGroup"
        scope_key   = "management"
        permissions = ["Contributor"]
      }
    }
  }
  connectivity_admins = {
    display_name = "Connectivity admins"
    permission_assignments = {
      assignment_01 = {
        scope       = "resourceGroup"
        scope_key   = "connectivity"
        permissions = ["Contributor", "Reader"]
      }
    }
  }
  security_operators = {
    display_name = "Security operators"
    permission_assignments = {
      assignment_01 = {
        scope       = "resourceGroup"
        scope_key   = "security"
        permissions = ["Security Admin"]
      }
    }
  }
}

# -------------------------------------------------------------------------------------------------------
# Network Interfaces
# -------------------------------------------------------------------------------------------------------
network_interfaces = {
  identity = {
    interface_configs = {
      vm-01 = {
        name                          = "internal"
        subnet                        = "WorkloadSubnet"
        private_ip_address_allocation = "Dynamic"
      }
    }
  }

  finance = {
    interface_configs = {
      vm-01 = {
        name                          = "internal"
        subnet                        = "WorkloadSubnet"
        private_ip_address_allocation = "Dynamic"
      }
    }
  }
}

# -------------------------------------------------------------------------------------------------------
# Virtual Machines
# -------------------------------------------------------------------------------------------------------
linux_virtual_machines = {
  identity = {
    vm_configs = {
      vm-01 = {
        os_disk = {
          caching              = "ReadWrite"
          storage_account_type = "Standard_LRS"
        }
        size = "Standard_F2s_v2"
        source_image_reference = {
          publisher = "Canonical"
          offer     = "ubuntu-24_04-lts"
          sku       = "server"
          version   = "latest"
        }
      }
    }
  }

  finance = {
    vm_configs = {
      vm-01 = {
        os_disk = {
          caching              = "ReadWrite"
          storage_account_type = "Standard_LRS"
        }
        size = "Standard_F2s_v2"
        source_image_reference = {
          publisher = "Canonical"
          offer     = "ubuntu-24_04-lts"
          sku       = "server"
          version   = "latest"
        }
      }
    }
  }
}

vm_credentials = {
  identity = {
    credentials = {
      vm-01 = {
        admin_username = "azuretester"
        admin_password = "Testing123456"
      }
    }
  }

  finance = {
    credentials = {
      vm-01 = {
        admin_username = "azuretester"
        admin_password = "Testing123456"
      }
    }
  }
}

# -------------------------------------------------------------------------------------------------------
# Public IP Addresses
# -------------------------------------------------------------------------------------------------------
public_ips = {
  connectivity = {
    pip_configs = {
      AzureBastion = {
        allocation_method = "Static"
        sku               = "Standard"
      }
      AzureFirewall = {
        allocation_method = "Static"
        sku               = "Standard"
      }
    }
  }
}

# -------------------------------------------------------------------------------------------------------
# Shared Services
# -------------------------------------------------------------------------------------------------------
shared_services = {
  connectivity = {
    service_configs = {
      AzureBastion = {
        sku    = "Basic"
        subnet = "AzureBastionSubnet"
        pip    = "AzureBastion"
      }
      AzureFirewall = {
        sku_name = "AZFW_VNet"
        sku_tier = "Standard"
        subnet   = "AzureFirewallSubnet"
        pip      = "AzureFirewall"
      }
    }
  }
}

# -------------------------------------------------------------------------------------------------------
# Route Tables
# -------------------------------------------------------------------------------------------------------
route_tables = {
  identity = {
    tables = {
      table-01 = {
        subnet = "WorkloadSubnet"
        routes = {
          route-01 = {
            name                   = "fw-default-gw"
            address_prefix         = "0.0.0.0/0"
            next_hop_type          = "VirtualAppliance"
            next_hop_in_ip_address = "10.30.2.4/24" # First usable address in firewall subnet
          }
        }
      }
    }
  }

  finance = {
    tables = {
      table-01 = {
        subnet = "WorkloadSubnet"
        routes = {
          route-01 = {
            name                   = "fw-default-gw"
            address_prefix         = "0.0.0.0/0"
            next_hop_type          = "VirtualAppliance"
            next_hop_in_ip_address = "10.30.2.4/24" # First usable address in firewall subnet
          }
        }
      }
    }
  }
}