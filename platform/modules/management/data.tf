# Get the current client configuration from the AzureRM provider
data "azurerm_client_config" "current" {}

# Get Subscription IDs from Vending Provisioning for Platform.
data "terraform_remote_state" "vending" {
  backend = "azurerm"
  config = {
    subscription_id      = "9fd0d299-f872-47d2-b400-91d27060b5d1" ## [TODO] Should be updated by retrieving from Vending output
    resource_group_name  = "rg-tfbackend"
    storage_account_name = "statlztfstatedev"
    container_name       = "bootstrap"
    key                  = "01-vending-dev.tfstate"
  }
}
