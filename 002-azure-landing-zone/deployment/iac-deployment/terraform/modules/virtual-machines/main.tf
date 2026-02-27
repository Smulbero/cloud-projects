# -------------------------------------------------------------------------------------------------------
# Network Interfaces 
# -------------------------------------------------------------------------------------------------------
resource "azurerm_network_interface" "this" {
  for_each = {
    for d in local.network_interfaces : d.key => d
  }

  # Required attributes
  name = format(
    "%s-%s",
    "nic",
    each.value.nic_key
  )
  resource_group_name = var.resource_groups[each.value.env_key].name
  location            = var.resource_groups[each.value.env_key].location

  ip_configuration {
    # Required attributes
    name                          = each.value.name
    private_ip_address_allocation = each.value.private_ip_address_allocation

    # Optional attributes
    subnet_id = var.virtual_networks[each.value.env_key].subnets[each.value.subnet].id
  }

  tags = merge(
    var.tags,
    var.resource_groups[each.value.env_key].tags,
    try(each.value.tags, {})
  )
}
# -------------------------------------------------------------------------------------------------------
# Virtual Machines
# -------------------------------------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "this" {
  for_each = {
    for d in local.linux_virtual_machines : d.key => d
  }

  # Required attributes
  name = format(
    "%s-%s",
    "vm",
    each.value.env_key
  )
  resource_group_name = var.resource_groups[each.value.env_key].name
  location            = var.resource_groups[each.value.env_key].location

  os_disk {
    caching              = each.value.os_disk.caching
    storage_account_type = each.value.os_disk.storage_account_type
  }
  size                  = each.value.size
  network_interface_ids = [azurerm_network_interface.this[each.value.key].id]

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }

  # Optional attributes
  computer_name  = each.value.computer_name != null ? each.value.computer_name : null
  admin_username = each.value.admin_username
  admin_password = each.value.admin_password
  # disable_password_authentication must be set to false if admin_password is specified
  disable_password_authentication = each.value.disable_password_authentication != null ? each.value.disable_password_authentication : false

  tags = merge(
    var.tags,
    var.resource_groups[each.value.env_key].tags,
    try(each.value.tags, {})
  )
}