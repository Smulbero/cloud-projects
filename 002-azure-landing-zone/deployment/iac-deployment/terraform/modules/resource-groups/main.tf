resource "azurerm_resource_group" "this" {
  for_each = var.resource_groups

  # Required attributes
  name = format(
    "%s-%s-%s",
    var.resource_groups_name_prefix,
    each.key,
    each.value.location
  )
  location = each.value.location

  # Optional attributes
  # If second value of merge has the same value as the first value, first value is overridden
  tags = merge(
    var.tags,
    try(each.value.tags, {})
  )
}