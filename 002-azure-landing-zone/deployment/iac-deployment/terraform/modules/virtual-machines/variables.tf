# -------------------------------------------------------------------------------------------------------
# Miscellaneous
# -------------------------------------------------------------------------------------------------------
variable "tags" {}
variable "resource_groups" {}
variable "virtual_networks" {}

# -------------------------------------------------------------------------------------------------------
# Network Interfaces
# -------------------------------------------------------------------------------------------------------
variable "network_interfaces" {
  description = <<EOT
    Network Interface Configurations
    Supports multiple interface configurations under 
    "interface_configs" object
  EOT

  type = map(object({
    interface_configs = map(object({
      name                          = string
      subnet                        = string
      private_ip_address_allocation = string
      tags                          = optional(map(string))
    }))
  }))
}

# -------------------------------------------------------------------------------------------------------
# Virtual Machines
# -------------------------------------------------------------------------------------------------------
variable "linux_virtual_machines" {
  description = "value"
  type = map(object({
    vm_configs = map(object({
      os_disk = object({
        caching              = string
        storage_account_type = optional(string)
      })
      size = string
      source_image_reference = object({
        publisher = string
        offer     = string
        sku       = string
        version   = string
      })
      admin_username                  = string
      admin_password                  = string
      disable_password_authentication = optional(bool)
      computer_name                   = optional(string)
      tags                            = optional(map(string))
    }))
  }))
}

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
        admin_username                  = vm.admin_username
        admin_password                  = vm.admin_password
        disable_password_authentication = try(vm.disable_password_authentication, null)
        computer_name                   = try(vm.computer_name, null)
        tags                            = try(vm.tags, null)
      }
    ]
  ])
}