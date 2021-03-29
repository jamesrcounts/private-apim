resource "azurerm_resource_group" "main" {
  name     = "rg-${local.project}"
  location = "centralus"
  tags     = local.tags
}

resource "azurerm_role_assignment" "keyvault_crypto_user" {
  for_each = {
    apim = azurerm_api_management.internal.identity.0.principal_id
  }

  principal_id         = each.value
  role_definition_name = "Key Vault Crypto User"
  scope                = azurerm_resource_group.main.id
}