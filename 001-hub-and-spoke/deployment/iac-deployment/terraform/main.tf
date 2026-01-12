# -------------------------------------------------------------------------------------------------------
# Resource Groups
# -------------------------------------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  for_each = var.resource_groups

  name = format(
    "%s-%s-%s",
    "rg",
    each.key,
    each.value.location
  )
  location = each.value.location

  tags = var.common_tags
}

# -------------------------------------------------------------------------------------------------------
# Virtual Networks
# -------------------------------------------------------------------------------------------------------
resource "azurerm_virtual_network" "this" {
  for_each = var.networks

  name = format(
    "%s-%s-%s",
    "vnet",
    each.key,
    azurerm_resource_group.this[each.key].location
  )
  location            = azurerm_resource_group.this[each.key].location
  resource_group_name = azurerm_resource_group.this[each.key].name
  address_space       = each.value.vnet_address_space
  dns_servers         = var.dns_servers

  tags = var.common_tags
}

# Subnets
resource "azurerm_subnet" "this" {
  # local.network_subnets is a list, so we must now project it into a map
  # where each key is unique. We'll combine the network and subnet keys to
  # produce a single unique key per instance.
  for_each = tomap({
    for d in local.network_subnets : "${d.vnet_key}.${d.subnet_key}" => d
  })

  name                 = each.value.subnet_name
  resource_group_name  = azurerm_resource_group.this[each.value.vnet_key].name
  virtual_network_name = azurerm_virtual_network.this[each.value.vnet_key].name
  address_prefixes     = each.value.subnet_address_space
}

# ------------------------------------------------------------------------------
# Network Security Groups
# ------------------------------------------------------------------------------
resource "azurerm_network_security_group" "this" {
  for_each = var.nsgs

  name = format(
    "%s-%s-%s",
    "nsg",
    each.key,
    azurerm_resource_group.this[each.key].location
  )
  location            = azurerm_resource_group.this[each.key].location
  resource_group_name = azurerm_resource_group.this[each.key].name

  tags = var.common_tags
}

# NSG rules
resource "azurerm_network_security_rule" "this" {
  for_each = tomap({
    for d in local.nsg_rules : "${d.env_key}.${d.rule_key}" => d
  })

  resource_group_name         = azurerm_network_security_group.this[each.value.env_key].resource_group_name
  network_security_group_name = azurerm_network_security_group.this[each.value.env_key].name

  name                       = each.value.rule_name
  priority                   = each.value.priority
  direction                  = each.value.direction
  access                     = each.value.access
  protocol                   = each.value.protocol
  source_port_range          = each.value.source_port_range
  destination_port_range     = each.value.destination_port_range
  source_address_prefix      = each.value.source_address_prefix
  destination_address_prefix = each.value.destination_address_prefix
}

# NSG associations
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = tomap({
    for d in local.nsg_associations : "${d.env_key}.${d.subnet_key}" => d
  })

  subnet_id                 = azurerm_subnet.this["${each.value.vnet_key}.${each.value.subnet_key}"].id
  network_security_group_id = azurerm_network_security_group.this[each.value.env_key].id
}

# ------------------------------------------------------------------------------
# Route Tables
# ------------------------------------------------------------------------------
resource "azurerm_route_table" "this" {
  for_each = var.route_tables

  name = format(
    "%s-%s-%s",
    "route",
    each.key,
    azurerm_resource_group.this[each.key].location
  )
  location            = azurerm_resource_group.this[each.key].location
  resource_group_name = azurerm_resource_group.this[each.key].name

  tags = var.common_tags
}

# Routes
resource "azurerm_route" "this" {
  for_each = tomap({
    for d in local.route_table_routes : "${d.env_key}.${d.route_key}" => d
  })

  name                   = each.value.route_name
  resource_group_name    = azurerm_resource_group.this[each.value.env_key].name
  route_table_name       = azurerm_route_table.this[each.value.env_key].name
  address_prefix         = each.value.route_address_prefix
  next_hop_type          = each.value.route_next_hop_type
  next_hop_in_ip_address = each.value.route_hop_in_ip_address
}

# Route table associations
resource "azurerm_subnet_route_table_association" "this" {
  for_each = tomap({
    for d in local.route_table_associations : "${d.env_key}.${d.vnet_key}.${d.subnet_key}" => d
  })

  subnet_id      = azurerm_subnet.this["${each.value.vnet_key}.${each.value.subnet_key}"].id
  route_table_id = azurerm_route_table.this[each.value.env_key].id
}

# ------------------------------------------------------------------------------
# Virtual Machines
# ------------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "this" {
  for_each = tomap({
    for d in local.vm_linux_configs : "${d.env_key}.${d.config_key}" => d
  })

  name = format(
    "%s-%s-%s-%s",
    "vm",
    each.value.env_key,
    azurerm_resource_group.this[each.value.env_key].location,
    substr(each.value.config_key, -2, -1)
  )
  resource_group_name = azurerm_resource_group.this[each.value.env_key].name
  location            = azurerm_resource_group.this[each.value.env_key].location

  size = each.value.size

  admin_username = each.value.admin_username
  admin_password = each.value.admin_password

  network_interface_ids = [azurerm_network_interface.this["${each.value.env_key}.${each.value.config_key}"].id]

  os_disk {
    caching              = each.value.caching
    storage_account_type = each.value.storage_account_type
  }

  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = each.value.version
  }

  tags = var.common_tags
}

# Network Interfaces
resource "azurerm_network_interface" "this" {
  for_each = tomap({
    for d in local.network_interface_configs : "${d.env_key}.${d.config_key}" => d
  })

  name = format(
    "%s-%s-%s-%s",
    "nic",
    each.value.env_key,
    each.value.config_key,
    azurerm_resource_group.this[each.value.env_key].location
  )
  location            = azurerm_resource_group.this[each.value.env_key].location
  resource_group_name = azurerm_resource_group.this[each.value.env_key].name

  ip_configuration {
    name                          = each.value.name
    subnet_id                     = azurerm_subnet.this["${each.value.env_key}.${each.value.subnet}"].id
    private_ip_address_allocation = each.value.private_ip_address_allocation
  }

  tags = var.common_tags
}

# ------------------------------------------------------------------------------
# Azure Bastion
# ------------------------------------------------------------------------------
resource "azurerm_bastion_host" "this" {
  for_each = var.azure_bastions

  name = format(
    "%s-%s-%s",
    "bastion",
    each.key,
    azurerm_resource_group.this[each.key].location
  )
  location            = azurerm_resource_group.this[each.key].location
  resource_group_name = azurerm_resource_group.this[each.key].name

  ip_configuration {
    name                 = var.bastion_config_name
    subnet_id            = azurerm_subnet.this["${each.key}.${each.value.subnet}"].id
    public_ip_address_id = azurerm_public_ip.this["${each.key}.${each.value.public_ip}"].id
  }

  tags = var.common_tags
}

# Azure Bastion Public IP
resource "azurerm_public_ip" "this" {
  for_each = tomap({
    for d in local.public_ip_configs : "${d.env_key}.${d.config_key}" => d
  })

  name = format(
    "%s-%s-%s-%s",
    each.value.config_key,
    "pip",
    each.value.env_key,
    azurerm_resource_group.this[each.value.env_key].location
  )
  resource_group_name = azurerm_resource_group.this[each.value.env_key].name
  location            = azurerm_resource_group.this[each.value.env_key].location

  allocation_method = each.value.allocation_method
  sku               = each.value.sku

  tags = var.common_tags
}

# ------------------------------------------------------------------------------
# Azure Firewall
# ------------------------------------------------------------------------------
resource "azurerm_firewall" "this" {
  for_each = var.azure_firewalls

  name = format(
    "%s-%s-%s",
    "fw",
    each.key,
    azurerm_resource_group.this[each.key].location
  )
  location            = azurerm_resource_group.this[each.key].location
  resource_group_name = azurerm_resource_group.this[each.key].name
  sku_name            = each.value.config.sku_name
  sku_tier            = each.value.config.sku_tier

  ip_configuration {
    name                 = var.firewall_config_name
    subnet_id            = azurerm_subnet.this["${each.key}.${each.value.config.subnet}"].id
    public_ip_address_id = azurerm_public_ip.this["${each.key}.${each.value.config.public_ip}"].id
  }

}

# Application rules
resource "azurerm_firewall_application_rule_collection" "this" {
  for_each = tomap({
    for d in local.firewall_app_rules : "${d.env_key}.${d.collection_key}" => d
  })

  name                = each.value.collection_name
  azure_firewall_name = azurerm_firewall.this[each.value.env_key].name
  resource_group_name = azurerm_resource_group.this[each.value.env_key].name
  priority            = each.value.priority
  action              = each.value.action

  rule {
    name             = each.value.rule_name
    source_addresses = each.value.source_addresses
    target_fqdns     = each.value.target_fqdns

    dynamic "protocol" {
      for_each = each.value.protocols
      content {
        port = protocol.value.port
        type = protocol.value.type

      }
    }
  }
}

# Network rules
resource "azurerm_firewall_network_rule_collection" "this" {
  for_each = tomap({
    for d in local.firewall_net_rules : "${d.env_key}.${d.collection_key}" => d
  })

  name                = each.value.collection_name
  azure_firewall_name = azurerm_firewall.this[each.value.env_key].name
  resource_group_name = azurerm_resource_group.this[each.value.env_key].name
  priority            = each.value.priority
  action              = each.value.action

  rule {
    name = each.value.rule_name

    source_addresses      = each.value.source_addresses
    destination_ports     = each.value.destination_ports
    destination_addresses = each.value.destination_addresses
    protocols             = each.value.protocols
  }
}

# ------------------------------------------------------------------------------
# Network Manager
# ------------------------------------------------------------------------------