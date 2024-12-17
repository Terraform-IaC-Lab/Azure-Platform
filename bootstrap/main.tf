terraform {
  required_version = "1.8.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.9.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.0.2"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.9.0" # Use the latest stable version
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfbackend"
    storage_account_name = "statlztfstatedev"
    container_name       = "bootstrap"
    key                  = "bootstrapidentity.tfstate"
  }
}

provider "azurerm" {
  features {}
}
provider "azapi" {
}

# Create Azure AD Application
resource "azuread_application" "service_principals" {
  #display_name = "sp_platform-dev-cd"
  for_each     = toset(var.service_principal_names)
  display_name = "sp-${each.value}"
  owners       = [data.azuread_client_config.current.object_id]
  # Configure OIDC federation
  feature_tags {
    enterprise = true
    gallery    = true
  }
}

# Create Service Principal
resource "azuread_service_principal" "service_principals" {
  #client_id                    = azuread_application.sp_platform-dev-cd.client_id
  for_each                     = toset(var.service_principal_names)
  client_id                    = azuread_application.service_principals[each.key].client_id
  app_role_assignment_required = true
  owners                       = [data.azuread_client_config.current.object_id]
}

# Configure OIDC Federation Credentials
resource "azuread_application_federated_identity_credential" "wif" {
  for_each       = toset(var.service_principal_names)
  application_id = azuread_application.service_principals[each.key].id
  display_name   = "wif-${each.value}"
  description    = "GitHub OIDC federation wif-${each.value}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:WITT-AZURE-PLATFORM/atlz-platform:environment:${each.value}" # Modify this according to your GitHub repo

  # You can add multiple subject patterns like:
  # subject = "repo:your-org/your-repo:ref:refs/heads/main"
  # subject = "repo:your-org/your-repo:pull_request"
}

module "subscription_role_assignment" {
  source   = "Azure/lz-vending/azurerm"
  version  = "v2.1.1"
  for_each = { for idx, ra in local.subscription_role_assignments : "${ra.subscription_id}-${ra.principal_id}" => ra }

  subscription_id         = each.value.subscription_id
  location                = var.location
  role_assignment_enabled = true

  role_assignments = [
    {
      principal_id   = each.value.principal_id
      definition     = each.value.definition
      relative_scope = each.value.relative_scope
    }
  ]

  subscription_alias_enabled = false
  virtual_network_enabled    = false
  disable_telemetry          = true
}

resource "azurerm_role_assignment" "mg_role_assignment" {
  for_each = { for idx, sp_name in var.service_principal_names : sp_name =>
    data.terraform_remote_state.identity.outputs.service_principals_ids[sp_name].service_principal_object_id
  }

  scope                = "/providers/Microsoft.Management/managementGroups/${data.azurerm_client_config.current.tenant_id}"
  role_definition_name = "Owner"
  principal_id         = each.value
}
resource "azurerm_role_assignment" "sp_storage_blob_contributor" {
  for_each = { for idx, sp_name in var.service_principal_names : sp_name =>
    data.terraform_remote_state.identity.outputs.service_principals_ids[sp_name].service_principal_object_id
  }
  scope                = "/subscriptions/${data.azurerm_client_config.current.boostrap_subscription_id}/resourceGroups/rg-tfbackend/providers/Microsoft.Storage/storageAccounts/sttfstatedev"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
}
