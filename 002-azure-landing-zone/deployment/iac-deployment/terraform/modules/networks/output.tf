output "virtual_networks" {
    description = "Map of virtual network objects, keyed by their map key"
    value = azurerm_virtual_network.this
}

output "network_peerings_from_hub" {
  value = azurerm_virtual_network_peering.hub_to_spoke
}

output "network_peerings_from_spoke" {
  value = azurerm_virtual_network_peering.spoke_to_hub
}