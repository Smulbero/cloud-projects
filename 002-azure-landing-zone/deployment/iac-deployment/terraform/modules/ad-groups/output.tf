output "ad_groups" {
  description = "Map of ad group objects, keyed by their map key"
  value = azuread_group.this
}