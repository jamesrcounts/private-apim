locals {
  project = "private-apim"

  tags = {
    project = local.project
  }
}

resource "random_pet" "fido" {}
data "azurerm_client_config" "current" {}