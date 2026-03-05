# -------------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------------
variable "tags" {}
variable "resource_groups" {}
variable "virtual_networks" {}
variable "network_interfaces" {}
variable "linux_virtual_machines" {}
variable "vm_credentials" {}

# -------------------------------------------------------------------------------------------------------
# Locals
# -------------------------------------------------------------------------------------------------------
locals {
  network_interfaces = flatten([
    for env_key, env in var.network_interfaces : [
      for nic_key, nic in env.interface_configs : {
        key                           = "${env_key}-${nic_key}"
        env_key                       = env_key
        nic_key                       = nic_key
        name                          = nic.name
        subnet                        = nic.subnet
        private_ip_address_allocation = nic.private_ip_address_allocation
        tags                          = try(nic.tags, null)
      }
    ]
  ])

  linux_virtual_machines = flatten([
    for env_key, env in var.linux_virtual_machines : [
      for vm_key, vm in env.vm_configs : {
        key                             = "${env_key}-${vm_key}"
        env_key                         = env_key
        vm_key                          = vm_key
        os_disk                         = vm.os_disk
        size                            = vm.size
        source_image_reference          = vm.source_image_reference
        credentials                     = var.vm_credentials[env_key].credentials[vm_key]
        disable_password_authentication = try(vm.disable_password_authentication, null)
        computer_name                   = try(vm.computer_name, null)
        tags                            = try(vm.tags, null)
      }
    ]
  ])  
}