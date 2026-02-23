# -------------------------------------------------------------------------------------------------------
# Resource Groups
# -------------------------------------------------------------------------------------------------------
module "resource_groups" {
  source = "./modules/resource-groups"
  resource_groups = var.resource_groups
}

# -------------------------------------------------------------------------------------------------------
# Virtual Networks
# -------------------------------------------------------------------------------------------------------
module "virtual_networks" {
  source = "./modules/networks"
  virtual_networks = var.virtual_networks
  resource_groups = module.resource_groups.resource_groups
}

# # -------------------------------------------------------------------------------------------------------
# # AD groups
# # -------------------------------------------------------------------------------------------------------
# # Create AD groups
# resource "azuread_group" "this" {
#   for_each = {
#     for d in local.ad_groups : d.key => d
#   }

#   # Required attributes
#   display_name = each.value.display_name
#   # mail_enabled or security_enabled must be specified
#   security_enabled = true

#   # Optional attributes
#   mail_nickname = each.value.mail_nickname
# }

# # -------------------------------------------------------------------------------------------------------
# # Role assignments
# # -------------------------------------------------------------------------------------------------------
# data "azurerm_subscription" "current" {
# }

# # Subscription scope
# resource "azurerm_role_assignment" "subscription" {
#   for_each = {
#     for d in local.ad_group_role_assignments : d.key => d
#     if d.scope == "subscription"
#   }

#   # Required attributes
#   scope = data.azurerm_subscription.current.id

#   # Optional attributes
#   role_definition_name = each.value.permission
#   principal_id         = azuread_group.this[each.value.group_key].object_id

#   depends_on = [azuread_group.this, data.azurerm_subscription.current]
# }

# # Resource group scope
# resource "azurerm_role_assignment" "resource_group" {
#   for_each = {
#     for d in local.ad_group_role_assignments : d.key => d
#     if d.scope_key != null && d.scope == "resourceGroup"
#   }

#   # Required attributes
#   scope = azurerm_resource_group.this[each.value.scope_key].id

#   # Optional attributes
#   role_definition_name = each.value.permission
#   principal_id         = azuread_group.this[each.value.group_key].object_id

#   depends_on = [azuread_group.this, azurerm_resource_group.this]
# }

# # -------------------------------------------------------------------------------------------------------
# # Policy definitions
# # -------------------------------------------------------------------------------------------------------
# data "local_file" "definition_file" {
#   for_each = { for k, v in local.policy_definition_file : k => v }
#   filename = "${path.root}/definition/${each.value.policy_ids}.json"
# }

# # Create custom policy definitions
# resource "azurerm_policy_definition" "this" {
#   for_each = { for k, v in local.policy_data : k => v }

#   # Required attributes
#   name         = each.value.metadata.name
#   policy_type  = "Custom"
#   mode         = each.value.mode
#   display_name = each.value.displayName

#   # Optional attributes
#   metadata    = jsonencode(each.value.metadata)
#   policy_rule = jsonencode(each.value.policyRule)

#   depends_on = [data.local_file.definition_file]
# }

# # Assigns every policy to subscription scope
# resource "azurerm_subscription_policy_assignment" "this" {
#   for_each = { for k, v in local.policy_data : k => v }

#   # Required attributes
#   name                 = each.value.metadata.name
#   policy_definition_id = azurerm_policy_definition.this[each.key].id
#   subscription_id      = data.azurerm_subscription.current.id

#   # Optional attributes

#   depends_on = [data.local_file.definition_file]
# }