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

variable "resource_groups" {
  description = ""
  type = map(object({
    name     = string
    location = string
    id       = string
  }))
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

variable "virtual_networks_name_prefix" {
  description = "Prefix value for virtual network name"
  type        = string
  default     = "vnet"
}

variable "hub_key" {
  description = "Key used for hub-and-spoke network topology"
  type        = string
  default     = "connectivity"
}

# -------------------------------------------------------------------------------------------------------
# Locals
# -------------------------------------------------------------------------------------------------------
locals {
  virtual_networks = flatten([
    for network_key, network in var.virtual_networks : {
      key                   = network_key
      network_key           = network_key
      network_name          = try(network.network_name, null)
      network_address_space = network.network_address_space
      subnets               = try(network.subnets, null)
      tags                  = try(network.tags, null)
    }
  ])

  spoke_networks = {
    for k, v in var.virtual_networks : k => v
    if k != "connectivity" && k != "hub"
  }
}