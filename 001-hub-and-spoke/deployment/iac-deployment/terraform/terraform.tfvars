# ------------------------------------------------------------------------------
# Miscellaneous
# ------------------------------------------------------------------------------
dns_servers = ["8.8.8.8", "8.8.4.4"]

public_ips = {
  hub = {
    ip_configs = {
      AzureBastion = {
        allocation_method = "Dynamic"
        sku               = "Standard"
      }
      AzureFirewall = {
        allocation_method = "Dynamic"
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
        subnet_name          = "WorkloadSubnetSubnet"
        subnet_address_space = ["10.10.16.0/24"]
      }
      testnet = {
        subnet_name          = "TestSubnet"
        subnet_address_space = ["10.10.17.0/24"]
      }
    }
  }

  marketing = {
    vnet_address_space = ["10.10.32.0/20"]
    subnets = {
      WorkloadSubnet = {
        subnet_name          = "WorkloadSubnetSubnet"
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
      allowrdpin = {
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
      subnets = ["WorkloadSubnet", "testnet"]
    }
  }

  marketing = {
    rules = {
      allowrdpin = {
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
        next_hop_in_ip_address = "10.10.1.4"
      }
    }
    associations = {
      sales     = ["WorkloadSubnet", "testnet"]
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
      interface_test = {
        name                          = "internal"
        subnet_association            = "testnet"
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
          sku       = "22_04_lts"
          version   = "latest"
        }
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