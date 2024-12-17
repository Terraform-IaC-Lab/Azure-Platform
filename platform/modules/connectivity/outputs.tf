# Output a copy of configure_connectivity_resources for use
# by the core module instance

output "configuration" {
  description = "Configuration settings for the \"connectivity\" resources."
  value       = local.configure_connectivity_resources
}

output "subscription_id_connectivity" {
  description = "Subscription ID for the \"connectivity\" resources."
  value       = data.terraform_remote_state.vending.outputs.subscription_id_connectivity
}

output "hub_vnet_id" { ### Will be used by Spoke VNet peering from ALZ Module
  description = "Resource ID of the hub virtual network"
  value       = module.plz.azurerm_virtual_network.connectivity
}

/* ### Unnecessary, for debug only
output "vpn_gateway_id" {
  description = "Resource ID of the virtual network gateway"
  value       = module.plz.azurerm_virtual_network_gateway.connectivity
}
*/
