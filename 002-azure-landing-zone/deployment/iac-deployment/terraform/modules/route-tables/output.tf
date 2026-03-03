output "route_tables" {
  description = "Map of route table objects, keyd by their map key"
  value = azurerm_route_table.this
}

output "route_table_associations" {
  description = "Map of route table associations, keyd by their map key"
  value = azurerm_subnet_route_table_association.this
}