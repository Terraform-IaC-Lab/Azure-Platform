output "service_principals_ids" {
  value = {
    for name in var.service_principal_names :
    name => {
      client_id                   = azuread_application.service_principals[name].client_id
      object_id                   = azuread_application.service_principals[name].object_id
      service_principal_object_id = azuread_service_principal.service_principals[name].object_id
    }
  }
}
