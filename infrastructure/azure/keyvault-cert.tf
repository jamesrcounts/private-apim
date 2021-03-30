resource "azurerm_key_vault_certificate" "gateway" {
  name         = "gateway-cert"
  key_vault_id = azurerm_key_vault.ops.id
  tags         = local.tags

  certificate {
    contents = filebase64("certificates/api.jamesrcounts.com.pfx")
    password = var.gateway_cert_password
  }

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }
}

resource "azurerm_key_vault_certificate" "portal" {
  name         = "portal-cert"
  key_vault_id = azurerm_key_vault.ops.id
  tags         = local.tags

  certificate {
    contents = filebase64("certificates/portal.jamesrcounts.com.pfx")
    password = var.portal_cert_password
  }

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }
}

