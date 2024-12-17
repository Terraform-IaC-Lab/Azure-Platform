# Configure the connectivity resources settings.
locals {
  configure_connectivity_resources = {
    settings = {
      hub_networks = [
        {
          enabled = true
          config = {
            address_space                = ["10.180.208.0/23", ]
            location                     = var.location
            link_to_ddos_protection_plan = false
            #dns_servers                  = []
            bgp_community = ""
            subnets = [
              {
                name             = "snet-sharedsvc"
                address_prefixes = ["10.180.208.128/27", ]
              },
              {
                name             = "snet-dnspr-in"
                address_prefixes = ["10.180.208.160/28", ]
              },
              {
                name             = "snet-dnspr-out"
                address_prefixes = ["10.180.208.176/28", ]
              },
              {
                name             = "AzureBastionSubnet"
                address_prefixes = ["10.180.208.192/26", ]
              },
            ]

            virtual_network_gateway = {
              enabled = true
              config = {
                address_prefix              = "10.180.208.64/26"
                gateway_sku_vpn             = "VpnGw1"
                remote_vnet_traffic_enabled = true
                advanced_vpn_settings = {
                  enable_bgp                       = true
                  active_active                    = false
                  private_ip_address_allocation    = ""
                  default_local_network_gateway_id = azurerm_local_network_gateway.onpremise.id
                  vpn_client_configuration         = []
                  bgp_settings = [
                    {
                      asn = 65515
                      peering_addresses = [
                        {
                          apipa_addresses = ["169.254.21.2"]
                        }
                      ]
                    }
                  ]
                  custom_route = []
                }
              }
            }

            azure_firewall = {
              enabled = true
              config = {
                address_prefix                = "10.180.208.0/26"
                enable_dns_proxy              = false
                dns_servers                   = []
                sku_tier                      = ""
                base_policy_id                = ""
                private_ip_ranges             = []
                threat_intelligence_mode      = ""
                threat_intelligence_allowlist = {}
                availability_zones = {
                  zone_1 = true
                }
              }
            }

            spoke_virtual_network_resource_ids      = []
            enable_outbound_virtual_network_peering = true
            enable_hub_network_mesh_peering         = false
          }
        },
      ]
      #vwan_hub_networks = []
      ddos_protection_plan = {
        enabled = false ### DDOS Protection be Disabled in Demo, [TBD]:for Dev/Prod Environment.
        config = {
          location = null
        }
      }
      dns = {
        enabled = false
        config = {
          location = null
          /*
          enable_private_link_by_service = {
            azure_api_management                = true
            azure_app_configuration_stores      = true
            azure_arc                           = true
            azure_automation_dscandhybridworker = true
            azure_automation_webhook            = true
            azure_backup                        = true
            azure_batch_account                 = true
            azure_bot_service_bot               = true
            azure_bot_service_token             = true
            azure_cache_for_redis                = true
            azure_cache_for_redis_enterprise     = true
            azure_container_registry             = true
            azure_cosmos_db_cassandra            = true
            azure_cosmos_db_gremlin              = true
            azure_cosmos_db_mongodb              = true
            azure_cosmos_db_sql                  = true
            azure_cosmos_db_table                = true
            azure_data_explorer                  = true
            azure_data_factory                   = true
            azure_data_factory_portal            = true
            azure_data_health_data_services      = true
            azure_data_lake_file_system_gen2     = true
            azure_database_for_mariadb_server    = true
            azure_database_for_mysql_server      = true
            azure_database_for_postgresql_server = true
            azure_digital_twins                  = true
            azure_event_grid_domain              = true
            azure_event_grid_topic               = true
            azure_event_hubs_namespace           = true
            azure_file_sync                      = true
            azure_hdinsights                     = true
            azure_iot_dps                        = true
            azure_iot_hub                        = true
            azure_key_vault             = true
            azure_key_vault_managed_hsm = true
            azure_kubernetes_service_management  = true
            azure_machine_learning_workspace     = true
            azure_managed_disks                  = true
            azure_media_services                 = true
            azure_migrate                        = true
            azure_monitor                        = true
            azure_purview_account                = true
            azure_purview_studio                 = true
            azure_relay_namespace                = true
            azure_search_service                 = true
            azure_service_bus_namespace          = true
            azure_site_recovery                  = true
            azure_sql_database_sqlserver         = true
            azure_synapse_analytics_dev          = true
            azure_synapse_analytics_sql          = true
            azure_synapse_studio                 = true
            azure_web_apps_sites                 = true
            azure_web_apps_static_sites          = true
            cognitive_services_account           = true
            microsoft_power_bi                   = true
            signalr                              = true
            signalr_webpubsub                    = true
            storage_account_blob  = true
            storage_account_file  = true
            storage_account_queue = true
            storage_account_table = true
            storage_account_web   = true
          }
          */
          private_link_locations = [
            #var.primary_location, var.secondary_location,
          ]
          public_dns_zones                                       = []
          private_dns_zones                                      = []
          enable_private_dns_zone_virtual_network_link_on_hubs   = true
          enable_private_dns_zone_virtual_network_link_on_spokes = true
          virtual_network_resource_ids_to_link                   = []
        }
      }
    }

    location = var.connectivity_resources_location
    tags     = var.connectivity_resources_tags
    advanced = {
      custom_settings_by_resource_type = {
        azurerm_public_ip = {
          connectivity_vpn = {
            germanywestcentral = {
              sku                 = "Standard"
              allocation_method   = "Static"
              public_ip_prefix_id = azurerm_public_ip_prefix.vpn_ips.id ### Allocate VPN public IP from reserved pool.
            }
          }
          /* Secondary VPN connection setting when active-active mode be enabled.
          connectivity_vpn_2 = {
            westeurope = {
              sku               = "Standard"
              allocation_method = "Static"
            }
          }
          */
        }
      }
    }
  }
}
