# -------------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------------
variable "tags" {}
variable "public_ips" {}
variable "resource_groups" {}
variable "virtual_networks" {}
variable "shared_services" {}
variable "public_ip_name_prefix" {
  default = "pip"
}
variable "bastion_name_prefix" {
  default = "bas"
}
variable "firewall_name_prefix" {
  default = "fw"
}
# -------------------------------------------------------------------------------------------------------
# Locals
# -------------------------------------------------------------------------------------------------------
locals {
  public_ips = flatten([
    for env_key, env in var.public_ips : [
      for pip_key, pip in env.pip_configs : {
        key     = "${env_key}-${pip_key}"
        env_key = env_key
        pip_key = pip_key
        pip     = pip
      }
    ]
  ])

  shared_services = flatten([
    for env_key, env in var.shared_services : [
      for service_key, service in env.service_configs : {
        key         = "${env_key}.${service_key}"
        env_key     = env_key
        service_key = service_key
        service     = service
      }
    ]
  ])
}