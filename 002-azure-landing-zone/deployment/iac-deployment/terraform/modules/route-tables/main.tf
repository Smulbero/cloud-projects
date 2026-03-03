# -------------------------------------------------------------------------------------------------------
# Creat Route Tables
# -------------------------------------------------------------------------------------------------------
resource "azurerm_route_table" "this" {
  for_each = { for d in local.route_tables : d.key => d }

  # Required attributes
  name = format(
    "%s-%s",
    var.route_table_name_prefix,
    each.value.env_key
  )
  resource_group_name = var.resource_groups[each.value.env_key].name
  location            = var.resource_groups[each.value.env_key].location

  # Optional attributes
  dynamic "route" {
    for_each = each.value.routes != null ? each.value.routes : {}
    content {
      # Required attributes
      name           = route.value.name
      address_prefix = route.value.address_prefix
      next_hop_type  = route.value.next_hop_type
      # Optional attributes
      # next_hop_in_ip_address = try(route.value.next_hop_in_ip_address, null)
      next_hop_in_ip_address = var.firewall["connectivity.AzureFirewall"].ip_configuration[0].private_ip_address
    }
  }

  tags = merge(
    var.tags,
    var.resource_groups[each.value.env_key].tags,
    try(each.value.route.tags, {})
  )
}

# -------------------------------------------------------------------------------------------------------
# Route Table associations
# -------------------------------------------------------------------------------------------------------
resource "azurerm_subnet_route_table_association" "this" {
  for_each = { for d in local.route_tables : d.key => d }

  # Required attributes
  route_table_id = azurerm_route_table.this[each.value.key].id
  subnet_id      = var.virtual_networks[each.value.env_key].subnets[each.value.table.subnet].id

}