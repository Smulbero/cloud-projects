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
  value = azurerm_virtual_network_peering.hub_to_spoke
}

output "network_peerings_from_spoke" {
  value = azurerm_virtual_network_peering.spoke_to_hub
}