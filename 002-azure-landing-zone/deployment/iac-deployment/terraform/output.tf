# # -------------------------------------------------------------------------------------------------------
# # Resource Groups
# # -------------------------------------------------------------------------------------------------------
# output "resource_groups" {
#   value = {
#     for k, v in module.resource_groups.resource_groups : k => {
#       name = v.name
#     }
#   }
# }

# # -------------------------------------------------------------------------------------------------------
# # Virtual Networks and Network Peerings
# # -------------------------------------------------------------------------------------------------------
# output "virtual_networks" {
#   value = {
#     for k, v in module.virtual_networks.virtual_networks : k => {
#       network_name    = v.name
#       network_subnets = v.subnet[*].name
#     }
#   }
# }

# output "network_peerings_from_hub" {
#   value = {
#     for k, v in module.virtual_networks.network_peerings_from_hub : k => {
#       peering_name = v.name
#     }
#   }
# }

# output "network_peerings_from_spoke" {
#   value = {
#     for k, v in module.virtual_networks.network_peerings_from_spoke : k => {
#       peering_name = v.name
#     }
#   }
# }

# # -------------------------------------------------------------------------------------------------------
# # Virtual Machines and their Network Interfaces
# # -------------------------------------------------------------------------------------------------------
# output "network_interfaces" {
#   value = {
#     for k, v in module.virtual_machines.network_interfaces : k => {
#       nic_name = v.name
#     }
#   }
# }

# output "linux_virtual_machines" {
#   value = {
#     for k, v in module.virtual_machines.linux_virtual_machines : k => {
#       vm_name = v.name
#     }
#   }
# }

# # -------------------------------------------------------------------------------------------------------
# # Shared Services
# # -------------------------------------------------------------------------------------------------------
# output "azure_bastion" {
#   value = module.shared_services.azure_bastion
# }

# output "azure_firewall" {
#   value = module.shared_services.azure_firewall
# }

# # -------------------------------------------------------------------------------------------------------
# # Route Tables and Associations
# # -------------------------------------------------------------------------------------------------------
# output "route_tables" {
#   value = module.route_tables.route_tables
# }

# output "route_table_associations" {
#   value = module.route_tables.route_table_associations
# }