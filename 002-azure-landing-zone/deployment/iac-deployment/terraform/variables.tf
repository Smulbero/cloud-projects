# -------------------------------------------------------------------------------------------------------
# Miscellaneous
# -------------------------------------------------------------------------------------------------------
variable "common_tags" {
  description = "Resource tags"
  type        = map(string)

  default = {
    terraform = true
  }
}

# -------------------------------------------------------------------------------------------------------
# Resource Groups
# -------------------------------------------------------------------------------------------------------
variable "resource_groups" {
  description = <<-EOT
    Resource group configuration.
    Each group is separated by a key such as "example_key"
    Each group block must have location property and optionally tags 
  EOT

  type = map(object({
    group_name = optional(string)
    location   = string
    tags       = optional(map(string))
  }))
}

variable "resource_groups_name_prefix" {
  description = "Prefix value for resource group name"
  type        = string
  default     = "rg"
}

# -------------------------------------------------------------------------------------------------------
# Virtual Networks
# -------------------------------------------------------------------------------------------------------
variable "virtual_networks" {
  description = <<-EOT
    Network configuration for VNets and subnets.
    Each network is separated by a key such as "example_key"
    Each network block supports multiple subnet configurations 
    under "subnets" object
  EOT

  type = map(object({
    network_name          = optional(string)
    network_address_space = list(string)
    subnets = optional(map(object({
      subnet_name          = optional(string)
      subnet_address_space = list(string)
    })))
    tags = optional(map(string))
  }))
}

# -------------------------------------------------------------------------------------------------------
# AD groups
# -------------------------------------------------------------------------------------------------------
variable "ad_groups" {
  description = <<-EOT
    AD group configurations
    Each group is separated by a key such as "group_01"
    Each group block supports multiple permission assignments 
    under "permission_assignments" object
  EOT

  type = map(object({
    display_name  = string
    mail_nickname = optional(string)
    permission_assignments = optional(map(object({
      scope       = string
      scope_key   = optional(string)
      permissions = list(string)
    })))
  }))
}

# -------------------------------------------------------------------------------------------------------
# Policy definitions
# -------------------------------------------------------------------------------------------------------
locals {
  # Load policy definition data from a CSV file and convert it into a list
  policy_definition_file = csvdecode(file("${path.root}/policy-definition/def-policy-csv/policyname.csv"))

  # Convert policy definition files to JSON format for Terraform use
  policy_data = { for name, file in data.local_file.policy_definition_file : name => jsondecode(file.content) }
}

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