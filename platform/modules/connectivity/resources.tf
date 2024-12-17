resource "azurerm_resource_group" "onpremise" { ### Provisioning of Resources for VPN connect to On-Premise PaloAlto
  name     = "rg-lgw-gwc-paloalto"
  location = var.location
}

resource "azurerm_public_ip_prefix" "vpn_ips" { ### Public IP Pool reserved for VPN connection
  name                = "ippre-vpn-gwc"
  location            = azurerm_resource_group.onpremise.location
  resource_group_name = azurerm_resource_group.onpremise.name
  prefix_length       = 31

  tags = {
    environment = "Production"
  }
}

resource "azurerm_local_network_gateway" "onpremise" { ### Provisioning of Resources for VPN connect to On-Premise PaloAlto
  name                = "lgw-gwc-paloalto"
  resource_group_name = azurerm_resource_group.onpremise.name
  location            = azurerm_resource_group.onpremise.location
  gateway_address     = "83.135.59.10" #Dummy IP for test only, should be "83.135.59.10"
  address_space       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  bgp_settings {
    asn                 = 65501
    bgp_peering_address = "169.254.21.1"
  }
}

resource "azurerm_virtual_network_gateway_connection" "onpremise" { ### Connection tunnel setting for VPN to On-Premise PaloAlto
  name                = "conn-ipsec-s2s-paloalto"
  location            = azurerm_resource_group.onpremise.location
  resource_group_name = azurerm_resource_group.onpremise.name

  type                       = "IPsec"
  virtual_network_gateway_id = keys(module.plz.azurerm_virtual_network_gateway.connectivity)[0]
  local_network_gateway_id   = azurerm_local_network_gateway.onpremise.id

  shared_key = var.vpn_shared_key

  connection_mode = "InitiatorOnly"
  enable_bgp      = true
  custom_bgp_addresses {
    primary = "169.254.21.2"
  }
  ipsec_policy {
    dh_group         = "DHGroup2"
    ike_encryption   = "AES256"
    ike_integrity    = "SHA256"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "None"
  }
}
