terraform {
  #required_version = "1.8.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.107"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = data.terraform_remote_state.vending.outputs.subscription_id_management
}

module "alz" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "6.2.0"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm
  }

  # Base module configuration settings
  root_parent_id            = data.azurerm_client_config.current.tenant_id
  root_id                   = var.root_id
  root_name                 = var.root_name
  default_location          = "westeurope"
  library_path              = "${path.module}/lib"
  disable_telemetry         = true
  deploy_core_landing_zones = true
  custom_landing_zones      = local.custom_landing_zones ### Customized Landing Zone setting in "locals" #
  # Will Move these subscriptions needed by platform to associated management groups for each.
  subscription_id_identity     = data.terraform_remote_state.vending.outputs.subscription_id_identity
  subscription_id_management   = data.terraform_remote_state.vending.outputs.subscription_id_management
  subscription_id_connectivity = data.terraform_remote_state.vending.outputs.subscription_id_connectivity
  # Configuration settings for identity resources is
  # bundled with core as no resources are actually created
  # for the identity subscription
  deploy_identity_resources    = true
  configure_identity_resources = local.configure_identity_resources
  #subscription_id_identity     = var.subscription_id_identity

  # The following inputs ensure that managed parameters are
  # configured correctly for policies relating to connectivity
  # resources created by the connectivity module instance and
  # to map the subscription to the correct management group,
  # but no resources are created by this module instance
  deploy_connectivity_resources    = false
  configure_connectivity_resources = var.configure_connectivity_resources
  #subscription_id_connectivity     = var.subscription_id_connectivity

  # The following inputs ensure that managed parameters are
  # configured correctly for policies relating to management
  # resources created by the management module instance and
  # to map the subscription to the correct management group,
  # but no resources are created by this module instance
  deploy_management_resources    = false
  configure_management_resources = var.configure_management_resources
  #subscription_id_management     = var.subscription_id_management
}
