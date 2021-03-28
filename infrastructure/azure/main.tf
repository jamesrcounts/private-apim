locals {
  project = "private-apim"

  tags = {
    project = local.project
  }
}

resource "random_pet" "fido" {}
