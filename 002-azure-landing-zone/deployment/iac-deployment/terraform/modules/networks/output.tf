output "virtual_networks" {
    description = "Map of virtual network objects, keyed by their map key"
    value = azurerm_virtual_network.this
}