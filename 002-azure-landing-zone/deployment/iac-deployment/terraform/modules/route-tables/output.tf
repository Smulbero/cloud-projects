output "route_tables" {
  description = "Map of route table objects, keyed by their map key"
  value = azurerm_route_table.this
}

output "route_table_associations" {
  description = "Map of route table associations, keyed by their map key"
  value = azurerm_subnet_route_table_association.this
}