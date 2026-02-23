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

# variable "virtual_networks_name_prefix" {
#   description = "Prefix value for virtual network name"
#   type        = string
#   default     = "vnet"
# }

# variable "hub_key" {
#   description = "Key used for hub-and-spoke network topology"
#   type        = string
#   default     = "connectivity"
# }

# locals {
#   virtual_networks = flatten([
#     for network_key, network in var.virtual_networks : {
#       key                   = network_key
#       network_key           = network_key
#       network_name          = try(network.network_name, null)
#       network_address_space = network.network_address_space
#       subnets               = try(network.subnets, null)
#       tags                  = try(network.tags, null)
#     }
#   ])

#   spoke_networks = {
#     for k, v in var.virtual_networks : k => v
#     if k != "connectivity" && k != "hub"
#   }
# }

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

locals {
  ad_groups = flatten([
    for group_key, group in var.ad_groups : {
      key                    = group_key
      group_key              = group_key
      display_name           = group.display_name
      mail_nickname          = try(group.mail_nickname, null)
      permission_assignments = try(group.permission_assignments, null)
    }
  ])

  ad_group_role_assignments = flatten([
    for group_key, group in var.ad_groups : [
      for assign_key, assignment in try(group.permission_assignments, {}) : [
        for permission in assignment.permissions : {
          key        = "${group_key}-${assign_key}-${permission}"
          group_key  = group_key
          scope      = assignment.scope
          scope_key  = try(assignment.scope_key, null)
          permission = permission
        }
      ]
    ]
  ])
}

# -------------------------------------------------------------------------------------------------------
# Policy definitions
# -------------------------------------------------------------------------------------------------------
# locals {
#   # Load policy definition data from a CSV file and convert it into a list
#   policy_definition_file = csvdecode(file("${path.root}/definition/def-policy-csv/policyname.csv"))

#   # Convert policy definition files to JSON format for Terraform use
#   policy_data = { for name, file in data.local_file.definition_file : name => jsondecode(file.content) }
# }

# # -------------------------------------------------------------------------------------------------------
# # Network Interfaces
# # -------------------------------------------------------------------------------------------------------
# variable "network_interfaces" {
#   description = <<EOT
#     Network Interface Configurations
#     Supports multiple interface configurations under 
#     "interface_configs" object
#   EOT

#   type = map(object({
#     interface_configs = map(object({
#       name                          = string
#       subnet_association            = string
#       private_ip_address_allocation = string
#     }))
#   }))
# }

# # -------------------------------------------------------------------------------------------------------
# # Virtual Machines
# # -------------------------------------------------------------------------------------------------------
# variable "virtual_machines_linux" {
#   description = "value"
#   type = map(object({
#     vm_configs = map(object({
#       size = string

#       os_disk = object({
#         caching              = string
#         storage_account_type = string
#       })

#       source_image_reference = object({
#         publisher = string
#         offer     = string
#         sku       = string
#         version   = string
#       })

#     }))
#   }))
# }