resource "azurerm_key_vault" "ops" {
  enable_rbac_authorization       = true
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  location                        = azurerm_resource_group.main.location
  name                            = "kv-${local.project}-ops"
  purge_protection_enabled        = false
  resource_group_name             = azurerm_resource_group.main.name
  sku_name                        = "standard"
  soft_delete_retention_days      = 30
  tags                            = local.tags
  tenant_id                       = data.azurerm_client_config.current.tenant_id
}