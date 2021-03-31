resource "azurerm_traffic_manager_profile" "tm" {
  name                   = "tm-${local.project}"
  resource_group_name    = azurerm_resource_group.main.name
  tags                   = local.tags
  traffic_routing_method = "Performance"
  traffic_view_enabled   = true

  dns_config {
    relative_name = local.project
    ttl           = 100
  }

  monitor_config {
    protocol                     = "https"
    port                         = 443
    path                         = "/status-0123456789abcdef"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
    custom_header {
      name  = "host"
      value = local.gateway_hostname
    }
  }
}

resource "azurerm_traffic_manager_endpoint" "agw" {
  name                = "tm-ep-${local.project}"
  profile_name        = azurerm_traffic_manager_profile.tm.name
  resource_group_name = azurerm_resource_group.main.name
  target_resource_id  = azurerm_public_ip.agw.id
  type                = "azureEndpoints"
}