output "resource_groups" {
  description = "Map of resource group objects, keyed by their map key"
  value = azurerm_resource_group.this
}