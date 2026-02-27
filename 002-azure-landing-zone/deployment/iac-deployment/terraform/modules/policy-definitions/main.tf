# -------------------------------------------------------------------------------------------------------
# Policy definitions
# -------------------------------------------------------------------------------------------------------
# Create custom policy definitions
resource "azurerm_policy_definition" "this" {
  for_each = { for k, v in var.policy_definitions : k => v }

  # Required attributes
  name         = each.value.metadata.name
  policy_type  = "Custom"
  mode         = each.value.mode
  display_name = each.value.displayName

  # Optional attributes
  metadata    = jsonencode(each.value.metadata)
  policy_rule = jsonencode(each.value.policyRule)
}

# Assigns every policy to subscription scope
resource "azurerm_subscription_policy_assignment" "this" {
  for_each = { for k, v in var.policy_definitions : k => v }

  # Required attributes
  name                 = each.value.metadata.name
  policy_definition_id = azurerm_policy_definition.this[each.key].id
  subscription_id      = var.subscription.id

  # Optional attributes
}