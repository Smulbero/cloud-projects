# -------------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------------
variable "tags" {}
variable "resource_groups" {}
variable "resource_groups_name_prefix" {
  description = "Prefix value for resource group name"
  type        = string
  default     = "rg"
}