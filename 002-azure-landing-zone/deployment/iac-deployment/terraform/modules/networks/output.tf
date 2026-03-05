output "virtual_networks" {
  description = "Map of virtual network objects, keyed by their map key"
  value = {
    for k, v in azurerm_virtual_network.this : k => merge(v, {
      subnets = {
        for subnet in v.subnet : subnet.name => subnet
      }
    })
  }
}

output "network_peerings_from_hub" {
  description = "Map of virtual network peering hub to spoke objects, keyed by their map key"
  value = azurerm_virtual_network_peering.hub_to_spoke
}

output "network_peerings_from_spoke" {
  description = "Map of virtual network peering spoke to hub objects, keyed by their map key"
  value = azurerm_virtual_network_peering.spoke_to_hub
}