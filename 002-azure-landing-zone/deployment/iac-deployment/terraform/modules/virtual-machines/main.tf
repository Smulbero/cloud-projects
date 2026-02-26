# -------------------------------------------------------------------------------------------------------
# Network Interfaces 
# -------------------------------------------------------------------------------------------------------
resource "azurerm_network_interface" "this" {
  
  # Required attributes
  name = ""
  resource_group_name = ""
  location = ""
  
  ip_configuration {
    # Required attributes
    name = ""
    private_ip_address_allocation = ""

    # Optional attributes
    subnet_id = ""    
  }
}
# -------------------------------------------------------------------------------------------------------
# Virtual Machines
# -------------------------------------------------------------------------------------------------------
resource "linux_virtual_machines" "this" {
  
  # Required attributes
    name = ""
    resource_group_name = ""
    location = ""

    os_disk = {
        caching = ""
        storage_account_type = ""
    }
    size = ""
    network_interface_id = ""

    # Optional attributes
    computer_name = try("", null)
    admin_username = ""
    admin_password = ""
    # disable_password_authentication must be set to false if admin_password is specified
    disable_password_authentication = try("", false)

    tags = merge(
    var.common_tags,
    try(each.value.tags, var.resource_groups[each.value.key].tags)
  )
}