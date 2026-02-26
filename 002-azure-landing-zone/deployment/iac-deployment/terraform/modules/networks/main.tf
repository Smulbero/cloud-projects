# -------------------------------------------------------------------------------------------------------
# Virtual Networks
# -------------------------------------------------------------------------------------------------------
resource "azurerm_virtual_network" "this" {
  for_each = {
    for d in local.virtual_networks : d.key => d
  }

  # Required attributes
  name = format(
    "%s-%s-%s",
    var.virtual_networks_name_prefix,
    each.value.key,
    var.resource_groups[each.value.key].location
  )
  location            = var.resource_groups[each.value.key].location
  resource_group_name = var.resource_groups[each.value.key].name

  # Optional attributes
  address_space = each.value.network_address_space

  dynamic "subnet" {
    for_each = each.value.subnets != null ? each.value.subnets : {}

    content {
      # Required attributes
      name             = subnet.value.subnet_name != null ? subnet.value.subnet_name : subnet.key
      address_prefixes = subnet.value.subnet_address_space

      # Optional attributes
    }
  }

  tags = merge(
    var.common_tags,
    try(each.value.tags, var.resource_groups[each.value.key].tags)
  )
}

# -------------------------------------------------------------------------------------------------------
# Network peerings - Hub and Spoke
# -------------------------------------------------------------------------------------------------------
# Hub to spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = local.spoke_networks

  # Required attributes
  name = format(
    "%s-%s",
    var.hub_key,
    each.key
  )
  virtual_network_name      = azurerm_virtual_network.this[var.hub_key].name
  resource_group_name       = var.resource_groups[var.hub_key].name
  remote_virtual_network_id = azurerm_virtual_network.this[each.key].id

  # Optional attributes
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  depends_on = [azurerm_virtual_network.this]
}

# Spoke to hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = local.spoke_networks

  # Required attributes
  name = format(
    "%s-%s",
    each.key,
    var.hub_key
  )
  virtual_network_name      = azurerm_virtual_network.this[each.key].name
  resource_group_name       = var.resource_groups[each.key].name
  remote_virtual_network_id = azurerm_virtual_network.this[var.hub_key].id

  # Optional attributes
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  depends_on = [azurerm_virtual_network.this]
}