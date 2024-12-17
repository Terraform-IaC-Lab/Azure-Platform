data "azuread_client_config" "current" {}
data "azurerm_client_config" "current" {}
data "terraform_remote_state" "vending" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-tfbackend"
    storage_account_name = "statlztfstatedev"
    container_name       = "bootstrap"
    key                  = "01-vending-dev.tfstate"
  }
}
data "terraform_remote_state" "identity" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-tfbackend"
    storage_account_name = "statlztfstatedev"
    container_name       = "bootstrap"
    key                  = "02-identity-dev.tfstate"
  }
}
