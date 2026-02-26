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
}

# -------------------------------------------------------------------------------------------------------
# Virtual Networks
# -------------------------------------------------------------------------------------------------------
module "virtual_networks" {
  source           = "./modules/networks"
  virtual_networks = var.virtual_networks
  resource_groups  = module.resource_groups.resource_groups
}

# -------------------------------------------------------------------------------------------------------
# AD groups and role assignments
# -------------------------------------------------------------------------------------------------------
module "ad_groups" {
  source          = "./modules/ad-groups"
  ad_groups       = var.ad_groups
  resource_groups = module.resource_groups.resource_groups
  subscription    = data.azurerm_subscription.current
}

# -------------------------------------------------------------------------------------------------------
# Policy definitions
# -------------------------------------------------------------------------------------------------------
module "policy_definitions" {
  source             = "./modules/policy-definitions"
  policy_definitions = local.policy_data
  subscription       = data.azurerm_subscription.current
}

# -------------------------------------------------------------------------------------------------------
# Virtual Machines
# -------------------------------------------------------------------------------------------------------
module "virtual_machines" {
  source                 = "./modules/virtual-machines"
  network_interfaces     = var.network_interfaces
  linux_virtual_machines = var.linux_virtual_machines
}