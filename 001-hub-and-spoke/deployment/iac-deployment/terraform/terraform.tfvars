# ------------------------------------------------------------------------------
# Important note
# ------------------------------------------------------------------------------
# Many if not all resources are linked together with "env_key" that MUST match
#
# Env_keys are based on resource group where resources will be deployed or where
# they are located.
#
# For example in this Hub-and-Spoke topology configuration, all resources that
# belong to rg-hub, are under a key of "hub"


# ------------------------------------------------------------------------------
# Miscellaneous
# ------------------------------------------------------------------------------
dns_servers = ["8.8.8.8", "8.8.4.4"]

public_ips = {
  hub = {
    ip_configs = {
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

# ------------------------------------------------------------------------------
# Resource Groups
# ------------------------------------------------------------------------------
resource_groups = {
  hub = {
    location = "northeurope"
  }
  sales = {
    location = "northeurope"
  }
  marketing = {
    location = "northeurope"
  }
  misc = {
    location = "northeurope"
  }
}

# ------------------------------------------------------------------------------
# Virtual Networks
# ------------------------------------------------------------------------------
networks = {
  hub = {
    vnet_address_space = ["10.10.0.0/20"]
    subnets = {
      AzureFirewallSubnet = {
        subnet_name          = "AzureFirewallSubnet"
        subnet_address_space = ["10.10.1.0/26"]
      }
      AzureBastionSubnet = {
        subnet_name          = "AzureBastionSubnet"
        subnet_address_space = ["10.10.2.0/26"]
      }
    }
  }

  sales = {
    vnet_address_space = ["10.10.16.0/20"]
    subnets = {
      WorkloadSubnet = {
        subnet_name          = "WorkloadSubnet"
        subnet_address_space = ["10.10.16.0/24"]
      }
    }
  }

  marketing = {
    vnet_address_space = ["10.10.32.0/20"]
    subnets = {
      WorkloadSubnet = {
        subnet_name          = "WorkloadSubnet"
        subnet_address_space = ["10.10.32.0/24"]
      }
    }
  }
}

# ------------------------------------------------------------------------------
# Network Security Groups
# ------------------------------------------------------------------------------
nsgs = {
  sales = {
    rules = {
      rule-01 = {
        rule_name                  = "AllowRdpIn"
        priority                   = "100"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "10.10.2.0/26"  # Azure Bastion Subnet
        destination_address_prefix = "10.10.16.0/20" # Sales address space
      }
    }
    associations = {
      subnets = ["WorkloadSubnet"]
    }
  }

  marketing = {
    rules = {
      rule-01 = {
        rule_name                  = "AllowRdpIn"
        priority                   = "100"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "10.10.2.0/26"  # Azure Bastion Subnet
        destination_address_prefix = "10.10.32.0/20" # Marketing address space
      }
    }
    associations = {
      subnets = ["WorkloadSubnet"]
    }
  }
}

# ------------------------------------------------------------------------------
# Route Tables
# ------------------------------------------------------------------------------
route_tables = {
  misc = {
    routes = {
      route-01 = {
        route_name             = "fw-default-gw"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.10.1.4" # First usable address in AzureFirewallSubnet
      }
    }
    associations = {
      sales     = ["WorkloadSubnet"]
      marketing = ["WorkloadSubnet"]
    }
  }
}

# ------------------------------------------------------------------------------
# Virtual Machines
# ------------------------------------------------------------------------------
network_interfaces = {
  sales = {
    interface_configs = {
      vm-01 = {
        name                          = "internal"
        subnet_association            = "WorkloadSubnet"
        private_ip_address_allocation = "Dynamic"
      }
    }
  }

  marketing = {
    interface_configs = {
      vm-01 = {
        name                          = "internal"
        subnet_association            = "WorkloadSubnet"
        private_ip_address_allocation = "Dynamic"
      }
    }
  }
}

virtual_machines_linux = {
  sales = {
    vm_configs = {
      vm-01 = {
        size = "Standard_F2"

        os_disk = {
          caching              = "None"
          storage_account_type = "Standard_LRS"
        }

        source_image_reference = {
          publisher = "Canonical"
          offer     = "0001-com-ubuntu-server-jammy"
          sku       = "22_04-lts-gen2"
          version   = "latest"
        }

        password_authentication = false
      }
    }
  }

  marketing = {
    vm_configs = {
      vm-01 = {
        size = "Standard_F2"

        os_disk = {
          caching              = "None"
          storage_account_type = "Standard_LRS"
        }

        source_image_reference = {
          publisher = "Canonical"
          offer     = "0001-com-ubuntu-server-jammy"
          sku       = "22_04_lts"
          version   = "latest"
        }

        password_authentication = false
      }
    }
  }
}

virtual_machine_credentials = {
  sales = {
    credential_configs = {
      vm-01 = {
        admin_username = "azuretester"
        admin_password = "Testing123456"
      }
    }
  }

  marketing = {
    credential_configs = {
      vm-01 = {
        admin_username = "azuretester"
        admin_password = "Testing123456"
      }
    }
  }
}

# ------------------------------------------------------------------------------
# Azure Bastion
# ------------------------------------------------------------------------------
azure_bastions = {
  hub = {
    subnet    = "AzureBastionSubnet"
    public_ip = "AzureBastion"
  }
}

# ------------------------------------------------------------------------------
# Azure Firewall
# ------------------------------------------------------------------------------
azure_firewalls = {
  hub = {
    config = {
      sku_name  = "AZFW_Hub"
      sku_tier  = "Standard"
      subnet    = "AzureFirewallSubnet"
      public_ip = "AzureFirewall"
    }

    app_rules = {
      app-collection-01 = {
        collection_name = "app-collection-01"
        priority        = "200"
        action          = "Allow"

        rules = {
          rule-01 = {
            rule_name        = "Allow-Google"
            source_addresses = ["10.10.0.0/20"]
            target_fqdns     = ["www.google.com"]
            protocols = {
              protocol-01 = {
                port = "443"
                type = "Https"
              }
              protocol-02 = {
                port = "80"
                type = "Http"
              }
            }
          }
        }
      }
    }

    net_rules = {
      net-collection-01 = {
        collection_name = "net-collection-01"
        priority        = "200"
        action          = "Allow"

        rules = {
          rule-01 = {
            rule_name             = "Allow-DNS"
            source_addresses      = ["10.10.0.0/20"]
            destination_ports     = ["53"]
            destination_addresses = ["8.8.8.8", "8.8.4.4"]
            protocols             = ["UDP"]
          }
        }
      }
    }
  }
}

# ------------------------------------------------------------------------------
# Network Manager
# ------------------------------------------------------------------------------
network_managers = {
  misc = {
    scope_accesses = ["Connectivity"]

    groups = {
      spoke-group = {
        name    = "spoke-networks-northeurope"
        netman  = "misc"
        members = ["sales", "marketing"]
      }
    }

    connectivity_configs = {
      hub-and-spoke = {
        name                  = "Hub-and-Spoke"
        connectivity_topology = "HubAndSpoke"
        applies_to_groups = {
          spoke-group = {
            group_connectivity = "None"
          }
        }
        hub = {
          resource_id   = "hub"
          resource_type = "Microsoft.Network/virtualNetworks"
        }
      }
    }

    deployment_configs = {
      misc = {
        scope_access     = "Connectivity"
        configuration_id = "misc.hub-and-spoke.spoke-group" # Resource key of flattened env_key, connectivity_key and group_key
      }
    }
  }
}
