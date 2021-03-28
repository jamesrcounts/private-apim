# $apimVirtualNetwork = New-AzApiManagementVirtualNetwork -SubnetResourceId $apimsubnetdata.Id
# $apimServiceName = "ContosoApi"       # API Management service instance name
# $apimOrganization = "Contoso"         # organization name
# $apimAdminEmail = "admin@contoso.com" # administrator's email address
# $apimService = New-AzApiManagement -ResourceGroupName $resGroupName -Location $location -Name $apimServiceName -Organization $apimOrganization -AdminEmail $apimAdminEmail -VirtualNetwork $apimVirtualNetwork -VpnType "Internal" -Sku "Developer"

resource "azurerm_api_management" "internal" {
  location             = azurerm_resource_group.main.location
  name                 = "${random_pet.fido.id}-api"
  publisher_email      = "admin@contoso.com"
  publisher_name       = "Contoso"
  resource_group_name  = azurerm_resource_group.main.name
  sku_name             = "Developer_1"
  virtual_network_type = "Internal"

  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim.id
  }
}