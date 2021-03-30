# $publicip = New-AzPublicIpAddress -ResourceGroupName $resGroupName -name "publicIP01" -location $location -AllocationMethod Dynamic

resource "azurerm_public_ip_prefix" "pib" {
  location            = azurerm_resource_group.main.location
  name                = "pib-${local.project}"
  prefix_length       = 31
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_public_ip" "agw" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.main.location
  name                = "pip-${local.project}-agw"
  public_ip_prefix_id = azurerm_public_ip_prefix.pib.id
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  tags                = local.tags
}