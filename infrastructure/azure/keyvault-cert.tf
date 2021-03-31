resource "azurerm_key_vault_certificate" "apim" {
  for_each = {
    gateway = {
      hostname = local.gateway_hostname
      password = var.gateway_cert_password
    }
    portal = {
      hostname = local.portal_hostname
      password = var.portal_cert_password
    }
  }

  name         = replace(each.value.hostname, ".", "-")
  key_vault_id = azurerm_key_vault.ops.id
  tags         = local.tags

  certificate {
    contents = filebase64("certificates/${each.value.hostname}.pfx")
    password = each.value.password
  }

  certificate_policy {
    issuer_parameters {
      name = "Unknown"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    lifetime_action {
      action {
        action_type = "EmailContacts"
      }

      trigger {
        lifetime_percentage = 50
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }
}
