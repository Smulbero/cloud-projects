# -------------------------------------------------------------------------------------------------------
# Public IP Addresses
# -------------------------------------------------------------------------------------------------------
resource "azurerm_public_ip" "this" {
  for_each = { for d in local.public_ips : d.key => d }

  # Required attributes
  name = format(
    "%s-%s-%s",
    var.public_ip_name_prefix,
    each.value.pip_key,
    each.value.env_key
  )
  resource_group_name = var.resource_groups[each.value.env_key].name

  # Optional attributes
  location          = var.resource_groups[each.value.env_key].location
  allocation_method = each.value.pip.allocation_method
  sku               = each.value.pip.sku

  tags = merge(
    var.tags,
    var.virtual_networks[each.value.env_key].tags,
    try(each.value.pip.tags, {})
  )
}

# -------------------------------------------------------------------------------------------------------
# Azure Bastion
# -------------------------------------------------------------------------------------------------------
resource "azurerm_bastion_host" "this" {
  for_each = {
    for d in local.shared_services : d.key => d
    if d.service_key == "AzureBastion"
  }

  # Required attributes
  name = format(
    "%s-%s",
    var.bastion_name_prefix,
    each.value.env_key
  )
  resource_group_name = var.resource_groups[each.value.env_key].name
  location            = var.resource_groups[each.value.env_key].location

  # Optional attributes
  sku = try(each.value.service.sku, null)
  ip_configuration {
    # Required attributes
    name                 = each.value.service.ip_configuration != null ? each.value.service.ip_configuration.name : "configuration"
    subnet_id            = var.virtual_networks[each.value.env_key].subnets[each.value.service.subnet].id
    public_ip_address_id = azurerm_public_ip.this["${each.value.env_key}-${each.value.service_key}"].id
  }

  tags = merge(
    var.tags,
    var.virtual_networks[each.value.env_key].tags,
    try(each.value.service.tags, {})
  )
}

# -------------------------------------------------------------------------------------------------------
# Azure Firewall
# -------------------------------------------------------------------------------------------------------
resource "azurerm_firewall" "this" {
  for_each = {
    for d in local.shared_services : d.key => d
    if d.service_key == "AzureFirewall"
  }

  # Required attributes
  name = format(
    "%s-%s",
    var.bastion_name_prefix,
    each.value.env_key
  )
  resource_group_name = var.resource_groups[each.value.env_key].name
  location            = var.resource_groups[each.value.env_key].location
  sku_name            = try(each.value.service.sku_name, "AZFW_VNet")
  sku_tier            = try(each.value.service.sku_tier, "Basic")

  # Optional attributes
  ip_configuration {
    # Required attributes
    name                 = each.value.service.ip_configuration != null ? each.value.service.ip_configuration.name : "configuration"
    subnet_id            = var.virtual_networks[each.value.env_key].subnets[each.value.service.subnet].id
    public_ip_address_id = azurerm_public_ip.this["${each.value.env_key}-${each.value.service_key}"].id
  }

  tags = merge(
    var.tags,
    var.virtual_networks[each.value.env_key].tags,
    try(each.value.service.tags, {})
  )
}