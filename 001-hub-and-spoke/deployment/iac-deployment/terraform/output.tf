# -------------------------------------------------------------------------------------------------------
# Miscellaneous
# -------------------------------------------------------------------------------------------------------
# output "resource_groups" {
#   value = {
#     for k, d in azurerm_resource_group.this :
#     k => {
#       rg_name = d.name
#     }
#   }
# }

# -------------------------------------------------------------------------------------------------------
# Virtual Networks
# -------------------------------------------------------------------------------------------------------
# output "networks" {
#   value = {
#     for k, d in azurerm_virtual_network.this :
#     k => {
#       vnet_name = d.name
#     }
#   }
# }

# output "subnets" {
#   value = {
#     for k, d in azurerm_subnet.this :
#     k => {
#       subnet_name = d.name
#       vnet_name   = d.virtual_network_name
#     }
#   }
# }

# -------------------------------------------------------------------------------------------------------
# Network Security Groups
# -------------------------------------------------------------------------------------------------------
# output "nsgs" {
#   value = {
#     for k, d in azurerm_network_security_group.this :
#     k => {
#       nsg_name = d.name
#     }
#   }
# }

# output "nsg_rules" {
#   value = {
#     for k, d in azurerm_subnet.this :
#     k => {
#       rule_name = d.name
#       nsg_name  = d.virtual_network_name
#     }
#   }
# }

# -------------------------------------------------------------------------------------------------------
# Route Tables
# -------------------------------------------------------------------------------------------------------
# output "route_tables" {
#   value = {
#     for k, d in azurerm_route_table.this :
#     k => {
#       table_name = d.name
#     }
#   }
# }

# output "route_tables_routes" {
#   value = {
#     for k, d in azurerm_route.this :
#     k => {
#       route_name = d.name
#     }
#   }
# }

# output "route_table_subnet_associations" {
#   value = {
#     for k, d in azurerm_subnet_route_table_association.this :
#     k => {
#       association_name = d
#     }
#   }
# }

# -------------------------------------------------------------------------------------------------------
# Virtual Machines
# -------------------------------------------------------------------------------------------------------
# output "network_interfaces" {
#   value = {
#     for k, d in azurerm_network_interface.this :
#     k => {
#       network_interface = d
#     }
#   }
# }

# output "virtual_machines_linux" {
#   value = {
#     for k, d in azurerm_linux_virtual_machine.this :
#     k => {
#       vm_name = d.name
#     }
#   }
# }

# ------------------------------------------------------------------------------
# Azure Bastion
# ------------------------------------------------------------------------------
# output "azure_bastion" {
#   value = {
#     for k, d in azurerm_bastion_host.this :
#     k => {
#       bastion = d
#     }
#   }
# }

# ------------------------------------------------------------------------------
# Azure Firewall
# ------------------------------------------------------------------------------
output "azure_firewall" {
  value = {
    for k, d in azurerm_firewall.this :
    k => {
      firewall = d
    }
  }
}

output "azure_firewall_app_rules" {
  value = {
    for k, d in azurerm_firewall_application_rule_collection.this :
    k => {
      app_rule = d
    }
  }
}

output "azure_firewall_net_rules" {
  value = {
    for k, d in azurerm_firewall_network_rule_collection.this :
    k => {
      net_rule = d
    }
  }
}

# ------------------------------------------------------------------------------
# Network Manager
# ------------------------------------------------------------------------------