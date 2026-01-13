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

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
}

# -------------------------------------------------------------------------------------------------------
# Resource Groups
# -------------------------------------------------------------------------------------------------------
variable "resource_groups" {
  description = "Resource Groups"
  type = map(object({
    location = string
  }))
}

# -------------------------------------------------------------------------------------------------------
# Virtual Networks
# -------------------------------------------------------------------------------------------------------
variable "networks" {
  description = "Networks"
  type = map(object({
    vnet_address_space = list(string)
    subnets = map(object({
      subnet_name          = string
      subnet_address_space = list(string)
    }))
  }))
}

locals {
  # flatten ensures that this local value is a flat list of objects, rather
  # than a list of lists of objects.
  network_subnets = flatten([
    for env_key, env in var.networks : [
      for subnet_key, subnet in env.subnets : {
        env_key              = env_key
        vnet_key             = env_key
        subnet_key           = subnet_key
        subnet_name          = subnet.subnet_name
        subnet_address_space = subnet.subnet_address_space
      }
    ]
  ])
}

# -------------------------------------------------------------------------------------------------------
# Network Security Groups
# -------------------------------------------------------------------------------------------------------
variable "nsgs" {
  description = "Network Security Groups"
  type = map(object({
    rules = map(object({
      rule_name                  = string
      priority                   = string
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string)
      destination_port_range     = optional(string)
      source_address_prefix      = optional(string)
      destination_address_prefix = optional(string)
    }))
    associations = map(list(string))
  }))
}

locals {
  nsg_rules = flatten([
    for env_key, env in var.nsgs : [
      for rule_key, rule in env.rules : {
        env_key                    = env_key
        rule_key                   = rule_key
        rule_name                  = rule.rule_name
        priority                   = rule.priority
        direction                  = rule.direction
        access                     = rule.access
        protocol                   = rule.protocol
        source_port_range          = try(rule.source_port_range, null)
        destination_port_range     = try(rule.destination_port_range, null)
        source_address_prefix      = try(rule.source_address_prefix, null)
        destination_address_prefix = try(rule.destination_address_prefix, null)
      }
    ]
  ])

  nsg_associations = flatten([
    for env_key, env in var.nsgs : [
      for subnet_key, subnets in env.associations : [
        for subnet in subnets : {
          env_key    = env_key
          vnet_key   = env_key
          subnet_key = subnet
        }
      ]
    ]
  ])
}

# -------------------------------------------------------------------------------------------------------
# Route Tables
# -------------------------------------------------------------------------------------------------------
variable "route_tables" {
  description = "Route Tables"
  type = map(object({
    routes = map(object({
      route_name             = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    }))
    associations = map(list(string))
  }))
}

locals {
  route_table_routes = flatten([
    for env_key, env in var.route_tables : [
      for route_key, route in env.routes : {
        env_key                 = env_key
        route_key               = route_key
        route_name              = route.route_name
        route_address_prefix    = route.address_prefix
        route_next_hop_type     = route.next_hop_type
        route_hop_in_ip_address = try(route.next_hop_in_ip_address, null)
      }
    ]
  ])

  route_table_associations = flatten([
    for env_key, env in var.route_tables : [
      for vnet_key, subnets in env.associations : [
        for subnet in subnets : {
          env_key    = env_key
          vnet_key   = vnet_key
          subnet_key = subnet
        }
      ]
    ]
  ])
}

# -------------------------------------------------------------------------------------------------------
# Virtual Machines
# -------------------------------------------------------------------------------------------------------
variable "virtual_machines_windows" {
  description = "Virtual Machines"
  type = map(object({
    vm_configs = map(object({
      size = string

      os_disk = object({
        caching              = string
        storage_account_type = string
      })

      source_image_reference = object({
        publisher = string
        offer     = string
        sku       = string
        version   = string
      })

      password_authentication = optional(bool)
    }))
  }))
}

variable "virtual_machine_credentials" {
  description = "VM Credentials"
  type = map(object({
    credential_configs = map(object({
      admin_username = string
      admin_password = string
    }))
  }))
  sensitive = true
}

variable "network_interfaces" {
  description = "Network Inferfaces"
  type = map(object({
    interface_configs = map(object({
      name                          = string
      subnet_association            = string
      private_ip_address_allocation = string
    }))
  }))
}

locals {
  vm_windows_configs = flatten([
    for env_key, env in var.virtual_machines_windows : [
      for config_key, config in env.vm_configs : {
        env_key                 = env_key
        config_key              = config_key
        size                    = config.size
        caching                 = config.os_disk.caching
        storage_account_type    = config.os_disk.storage_account_type
        publisher               = config.source_image_reference.publisher
        offer                   = config.source_image_reference.offer
        sku                     = config.source_image_reference.sku
        version                 = config.source_image_reference.version
        admin_username          = var.virtual_machine_credentials[env_key].credential_configs[config_key].admin_username
        admin_password          = var.virtual_machine_credentials[env_key].credential_configs[config_key].admin_password
        password_authentication = try(config.password_authentication, null)
      }
    ]]
  )

  network_interface_configs = flatten([
    for env_key, env in var.network_interfaces : [
      for config_key, config in env.interface_configs : {
        env_key                       = env_key
        config_key                    = config_key
        name                          = config.name
        subnet                        = config.subnet_association
        private_ip_address_allocation = config.private_ip_address_allocation
      }
    ]
  ])
}

# ------------------------------------------------------------------------------
# Azure Bastion
# ------------------------------------------------------------------------------
variable "azure_bastions" {
  description = "Azure Bastions"
  type = map(object({
    subnet    = string
    public_ip = string
  }))
}

variable "bastion_config_name" {
  description = "Basion configuration name attribute"
  type        = string
  default     = "configuration"
}

# ------------------------------------------------------------------------------
# Azure Firewall
# ------------------------------------------------------------------------------
variable "azure_firewalls" {
  description = "Azure Firewalls"
  type = map(object({
    config = object({
      sku_name  = string
      sku_tier  = string
      subnet    = string
      public_ip = string
    })

    app_rules = map(object({
      collection_name = string
      priority        = number
      action          = string
      rules = map(object({
        rule_name        = string
        source_addresses = optional(list(string))
        target_fqdns     = optional(list(string))
        protocols = optional(map(object({
          port = number
          type = string
        })))
      }))
    }))

    net_rules = map(object({
      collection_name = string
      priority        = number
      action          = string
      rules = map(object({
        rule_name             = string
        source_addresses      = optional(list(string))
        destination_ports     = list(string)
        destination_addresses = list(string)
        protocols             = list(string)
      }))
    }))
  }))
}

variable "firewall_config_name" {
  description = "Firewall configuration name attribute"
  type        = string
  default     = "configuration"
}

locals {
  firewall_app_rules = flatten([
    for env_key, env in var.azure_firewalls : [
      for collection_key, collection in env.app_rules : [
        for rule_key, rule in collection.rules : {

          env_key        = env_key
          collection_key = collection_key
          rule_key       = rule_key

          collection_name = collection.collection_name
          priority        = collection.priority
          action          = collection.action

          rule_name        = rule.rule_name
          source_addresses = try(rule.source_addresses, null)
          target_fqdns     = try(rule.target_fqdns, null)
          protocols        = rule.protocols
        }
      ]
    ]
    ]
  )

  firewall_net_rules = flatten([
    for env_key, env in var.azure_firewalls : [
      for collection_key, collection in env.net_rules : [
        for rule_key, rule in collection.rules : {
          env_key        = env_key
          collection_key = collection_key
          rule_key       = rule_key

          collection_name = collection.collection_name
          priority        = collection.priority
          action          = collection.action

          rule_name             = rule.rule_name
          source_addresses      = try(rule.source_addresses, null)
          destination_ports     = rule.destination_ports
          destination_addresses = rule.destination_addresses
          protocols             = rule.protocols
        }
      ]
    ]
  ])
}

# ------------------------------------------------------------------------------
# Public IP Addresses
# ------------------------------------------------------------------------------
variable "public_ips" {
  description = "Public IP addresses"
  type = map(object({
    ip_configs = map(object({
      allocation_method = string
      sku               = optional(string)
    }))
  }))
}

locals {
  public_ip_configs = flatten([
    for env_key, env in var.public_ips : [
      for config_key, config in env.ip_configs : {
        env_key           = env_key
        config_key        = config_key
        allocation_method = config.allocation_method
        sku               = try(config.sku, null)
      }
    ]
  ])
}

# ------------------------------------------------------------------------------
# Network Manager
# ------------------------------------------------------------------------------
variable "network_managers" {
  description = "Network Managers"
  type = map(object({
    scope_accesses = list(string)

    groups = map(object({
      name    = string
      netman  = string
      members = list(string)
    }))

    connectivity_configs = map(object({
      name                  = string
      connectivity_topology = string
      applies_to_groups = map(object({
        group_connectivity = string
      }))
      hub = object({
        resource_id   = string
        resource_type = string
      })
    }))

    deployment_configs = map(object({
      scope_access     = string
      configuration_id = string
    }))
  }))
}

locals {
  netman_groups = flatten([
    for env_key, env in var.network_managers : [
      for group_key, group in env.groups : {
        env_key   = env_key
        group_key = group_key
      }
    ]
  ])

  netman_group_members = flatten([
    for env_key, env in var.network_managers : [
      for group_key, group in env.groups : [
        for member_key, member in group.members : {
          env_key    = env_key
          group_key  = group_key
          member_key = member_key
          member     = member
          name       = group.name
        }
      ]
    ]
  ])

  netman_connectivity_configs = flatten([
    for env_key, env in var.network_managers : [
      for config_key, config in env.connectivity_configs : [
        for group_key, group in config.applies_to_groups : {
          env_key               = env_key
          config_key            = config_key
          group_key             = group_key
          name                  = config.name
          connectivity_topology = config.connectivity_topology
          groups                = config.applies_to_groups
          hub                   = config.hub
        }
      ]
    ]
  ])

  netman_deployment_configs = flatten([
    for env_key, env in var.network_managers : [
      for config_key, config in env.deployment_configs : {
        env_key          = env_key
        config_key       = config_key
        scope_access     = config.scope_access
        configuration_id = config.configuration_id
      }
    ]
  ])
}