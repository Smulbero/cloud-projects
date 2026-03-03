# -------------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------------
variable "tags" {}
variable "resource_groups" {}
variable "virtual_networks" {}
variable "route_tables" {}
variable "route_table_name_prefix" {
  default = "rt"
}
variable "firewall" {}

# -------------------------------------------------------------------------------------------------------
# Locals
# -------------------------------------------------------------------------------------------------------
locals {
  route_tables = flatten([
    for env_key, env in var.route_tables : [
      for table_key, table in env.tables : {
        key       = "${env_key}-${table_key}"
        env_key   = env_key
        table_key = table_key
        table     = table
        routes    = table.routes
      }
    ]
  ])
}