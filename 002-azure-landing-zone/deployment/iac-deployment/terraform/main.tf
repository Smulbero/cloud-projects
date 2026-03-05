# -------------------------------------------------------------------------------------------------------
# Data sources
# -------------------------------------------------------------------------------------------------------
data "azurerm_subscription" "current" {}

data "local_file" "policy_definition_file" {
  for_each = { for k, v in local.policy_definition_file : k => v }
  filename = "${path.root}/policy-definition/${each.value.policy_ids}.json"
}

# -------------------------------------------------------------------------------------------------------
# Resource Groups
# -------------------------------------------------------------------------------------------------------
module "resource_groups" {
  source          = "./modules/resource-groups"
  resource_groups = var.resource_groups
  tags            = var.common_tags
}

# -------------------------------------------------------------------------------------------------------
# Policy definitions and Assignments
# -------------------------------------------------------------------------------------------------------
module "policy_definitions" {
  source             = "./modules/policy-definitions"
  policy_definitions = local.policy_data
  subscription       = data.azurerm_subscription.current
}

# -------------------------------------------------------------------------------------------------------
# Virtual Networks and Network Peerings
# -------------------------------------------------------------------------------------------------------
module "virtual_networks" {
  source           = "./modules/networks"
  virtual_networks = var.virtual_networks
  resource_groups  = module.resource_groups.resource_groups
  tags             = var.common_tags
}

# -------------------------------------------------------------------------------------------------------
# AD groups and Role Assignments
# -------------------------------------------------------------------------------------------------------
module "ad_groups" {
  source          = "./modules/ad-groups"
  ad_groups       = var.ad_groups
  resource_groups = module.resource_groups.resource_groups
  subscription    = data.azurerm_subscription.current
}

# -------------------------------------------------------------------------------------------------------
# Virtual Machines and their Network Interfaces
# -------------------------------------------------------------------------------------------------------
module "virtual_machines" {
  source                 = "./modules/virtual-machines"
  network_interfaces     = var.network_interfaces
  linux_virtual_machines = var.linux_virtual_machines
  vm_credentials         = var.vm_credentials
  resource_groups        = module.resource_groups.resource_groups
  virtual_networks       = module.virtual_networks.virtual_networks
  tags                   = var.common_tags
}

# -------------------------------------------------------------------------------------------------------
# Shared Services
# -------------------------------------------------------------------------------------------------------
module "shared_services" {
  source           = "./modules/shared-services"
  public_ips       = var.public_ips
  resource_groups  = module.resource_groups.resource_groups
  virtual_networks = module.virtual_networks.virtual_networks
  shared_services  = var.shared_services
  tags             = var.common_tags
}

# -------------------------------------------------------------------------------------------------------
# Route Tables and Associations
# -------------------------------------------------------------------------------------------------------
module "route_tables" {
  source           = "./modules/route-tables"
  route_tables     = var.route_tables
  resource_groups  = module.resource_groups.resource_groups
  virtual_networks = module.virtual_networks.virtual_networks
  firewall      = module.shared_services.azure_firewall
  tags             = var.common_tags
}