# -------------------------------------------------------------------------------------------------------
# Miscellaneous
# -------------------------------------------------------------------------------------------------------
variable "resource_groups" {
  description = ""
  type = map(object({
    id = string
    name = string
    location = string
  }))
}

variable "subscription" {}

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