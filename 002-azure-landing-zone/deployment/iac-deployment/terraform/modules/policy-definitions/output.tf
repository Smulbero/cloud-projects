output "policy_definitions" {
  description = "Map of policy definition objects, keyad by their map key"
  value = azurerm_policy_definition.this
}