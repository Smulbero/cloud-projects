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