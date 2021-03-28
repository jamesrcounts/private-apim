# $vnet = New-AzVirtualNetwork -Name "appgwvnet" -ResourceGroupName $resGroupName -Location $location -AddressPrefix "10.0.0.0/16" -Subnet $appgatewaysubnet,$apimsubnet
resource "azurerm_virtual_network" "hub" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  name                = "appgwvnet"
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

# $appgatewaysubnet = New-AzVirtualNetworkSubnetConfig -Name "apim01" -AddressPrefix "10.0.0.0/24"
resource "azurerm_subnet" "agw" {
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.hub.address_space.0, 8, 0)]
  name                 = "apim01"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub.name
}

# $apimsubnet = New-AzVirtualNetworkSubnetConfig -Name "apim02" -AddressPrefix "10.0.1.0/24"
resource "azurerm_subnet" "apim" {
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.hub.address_space.0, 8, 1)]
  name                 = "apim02"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub.name
}
