# -------------------------------------------------------------------------------------------------------
# AD groups
# -------------------------------------------------------------------------------------------------------
resource "azuread_group" "this" {
  for_each = {
    for d in local.ad_groups : d.key => d
  }

  # Required attributes
  display_name = each.value.display_name
  # mail_enabled or security_enabled must be specified
  security_enabled = true

  # Optional attributes
  mail_nickname = each.value.mail_nickname
}

# -------------------------------------------------------------------------------------------------------
# Role assignments
# -------------------------------------------------------------------------------------------------------
# Subscription scope
resource "azurerm_role_assignment" "subscription" {
  for_each = {
    for d in local.ad_group_role_assignments : d.key => d
    if d.scope == "subscription"
  }

  # Required attributes
  scope = var.subscription.id

  # Optional attributes
  role_definition_name = each.value.permission
  principal_id         = azuread_group.this[each.value.group_key].object_id
}

# Resource group scope
resource "azurerm_role_assignment" "resource_group" {
  for_each = {
    for d in local.ad_group_role_assignments : d.key => d
    if d.scope_key != null && d.scope == "resourceGroup"
  }

  # Required attributes
  scope = var.resource_groups[each.value.scope_key].id

  # Optional attributes
  role_definition_name = each.value.permission
  principal_id         = azuread_group.this[each.value.group_key].object_id
}