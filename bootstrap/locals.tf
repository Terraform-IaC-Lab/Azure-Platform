locals {
  # Create subscription role assignments
  subscription_role_assignments = flatten([
    for sub_name, sub_id in {
      connectivity = data.terraform_remote_state.vending.outputs.subscription_id_connectivity,
      identity     = data.terraform_remote_state.vending.outputs.subscription_id_identity,
      management   = data.terraform_remote_state.vending.outputs.subscription_id_management
      } : [
      for sp_name in var.service_principal_names : {
        subscription_id = sub_id
        principal_id    = data.terraform_remote_state.identity.outputs.service_principals_ids[sp_name].service_principal_object_id
        definition      = sp_name == "platform-dev" ? "Contributor" : "Reader"
        relative_scope  = ""
      }
    ]
  ])
}
