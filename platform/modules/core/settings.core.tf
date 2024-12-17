locals {
  custom_landing_zones = {
    "${var.root_id}-internal" = {
      display_name               = "Workloads via Internal Access"
      parent_management_group_id = "${var.root_id}-landing-zones"
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "default_empty"
        parameters     = {}
        access_control = {}
      }
    }
    "${var.root_id}-external" = {
      display_name               = "Workloads via External Access"
      parent_management_group_id = "${var.root_id}-landing-zones"
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "default_empty"
        parameters     = {}
        access_control = {}
      }
    }
    "${var.root_id}-uc01" = {
      display_name               = "Usecase 01"
      parent_management_group_id = "${var.root_id}-internal"
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "uc01"
        parameters     = {}
        access_control = {}
      }
    }
    "${var.root_id}-uc02" = {
      display_name               = "Usecase 02"
      parent_management_group_id = "${var.root_id}-internal"
      subscription_ids           = []
      archetype_config = {
        archetype_id   = "default_empty"
        parameters     = {}
        access_control = {}
      }
    }
  }
}
