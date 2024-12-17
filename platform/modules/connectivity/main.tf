terraform {
  required_version = "~> 1.8.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.107.0"
    }
  }
  backend "azurerm" {
    #  subscription_id      = "9fd0d299-f872-47d2-b400-91d27060b5d1"
    #  resource_group_name  = "rg-tfbackend"
    #  storage_account_name = "statlztfstatedev"
    #  container_name       = "platform"
    #  key                  = "11-connectivity.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = data.terraform_remote_state.vending.outputs.subscription_id_connectivity
}

module "plz" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "6.1.0"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm
  }

  # Base module configuration settings
  root_parent_id = data.azurerm_client_config.current.tenant_id
  root_id        = var.root_id
  #root_name        = var.root_name
  default_location = var.location

  # Disable creation of the core management group hierarchy
  # as this is being created by the core module instance
  deploy_core_landing_zones = false

  # Configuration settings for connectivity resources
  deploy_connectivity_resources    = var.deploy_connectivity_resources
  configure_connectivity_resources = local.configure_connectivity_resources
  subscription_id_connectivity     = data.terraform_remote_state.vending.outputs.subscription_id_connectivity

  depends_on = [
    azurerm_resource_group.onpremise,
    azurerm_local_network_gateway.onpremise,
    azurerm_public_ip_prefix.vpn_ips
  ]
}
