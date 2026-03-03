# -------------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------------
variable "tags" {}
variable "resource_groups" {}
variable "virtual_networks" {}
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