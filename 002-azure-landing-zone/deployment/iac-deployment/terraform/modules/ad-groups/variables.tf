# -------------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------------
variable "resource_groups" {}
variable "subscription" {}
variable "ad_groups" {}

# -------------------------------------------------------------------------------------------------------
# Locals
# -------------------------------------------------------------------------------------------------------
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