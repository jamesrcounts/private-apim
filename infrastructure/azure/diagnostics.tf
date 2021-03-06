locals {
  monitored_services = {
    apim = azurerm_api_management.internal.id
    agw  = azurerm_application_gateway.agw.id
    kv   = azurerm_key_vault.ops.id
    la   = azurerm_log_analytics_workspace.insights.id
    pip  = azurerm_public_ip.agw.id
    tm   = azurerm_traffic_manager_profile.tm.id
    vnet = azurerm_virtual_network.hub.id
  }
}

data "azurerm_monitor_diagnostic_categories" "categories" {
  for_each = local.monitored_services

  resource_id = each.value
}

resource "azurerm_monitor_diagnostic_setting" "setting" {
  for_each = local.monitored_services

  name                           = "diag-${each.key}"
  target_resource_id             = each.value
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.insights.id
  log_analytics_destination_type = each.key == "apim" ? "Dedicated" : null

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories[each.key].logs

    content {
      category = log.value
      enabled  = true

      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories[each.key].metrics

    content {
      category = metric.value
      enabled  = true

      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }
}