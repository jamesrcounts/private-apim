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

# $gatewayHostname = "api.contoso.net"                 # API gateway host
# $portalHostname = "portal.contoso.net"               # API developer portal host
# $gatewayCertCerPath = "C:\Users\Contoso\gateway.cer" # full path to api.contoso.net .cer file
# $gatewayCertPfxPath = "C:\Users\Contoso\gateway.pfx" # full path to api.contoso.net .pfx file
# $portalCertPfxPath = "C:\Users\Contoso\portal.pfx"   # full path to portal.contoso.net .pfx file
# $gatewayCertPfxPassword = "certificatePassword123"   # password for api.contoso.net pfx certificate
# $portalCertPfxPassword = "certificatePassword123"    # password for portal.contoso.net pfx certificate

# $certPwd = ConvertTo-SecureString -String $gatewayCertPfxPassword -AsPlainText -Force
# $certPortalPwd = ConvertTo-SecureString -String $portalCertPfxPassword -AsPlainText -Force

# $proxyHostnameConfig = New-AzApiManagementCustomHostnameConfiguration -Hostname $gatewayHostname -HostnameType Proxy -PfxPath $gatewayCertPfxPath -PfxPassword $certPwd
# $portalHostnameConfig = New-AzApiManagementCustomHostnameConfiguration -Hostname $portalHostname -HostnameType DeveloperPortal -PfxPath $portalCertPfxPath -PfxPassword $certPortalPwd

# $apimService.ProxyCustomHostnameConfiguration = $proxyHostnameConfig
# $apimService.PortalCustomHostnameConfiguration = $portalHostnameConfig
# Set-AzApiManagement -InputObject $apimService