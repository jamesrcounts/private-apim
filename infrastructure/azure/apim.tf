# $gatewayHostname = "api.contoso.net"                 # API gateway host
# $portalHostname = "portal.contoso.net"               # API developer portal host
locals {
  gateway_hostname   = "api.jamesrcounts.com"
  portal_hostname    = "portal.jamesrcounts.com"
  apim_resource_name = "${random_pet.fido.id}-api"
}


# $apimVirtualNetwork = New-AzApiManagementVirtualNetwork -SubnetResourceId $apimsubnetdata.Id
# $apimServiceName = "ContosoApi"       # API Management service instance name
# $apimOrganization = "Contoso"         # organization name
# $apimAdminEmail = "admin@contoso.com" # administrator's email address
# $apimService = New-AzApiManagement -ResourceGroupName $resGroupName -Location $location -Name $apimServiceName -Organization $apimOrganization -AdminEmail $apimAdminEmail -VirtualNetwork $apimVirtualNetwork -VpnType "Internal" -Sku "Developer"
# $proxyHostnameConfig = New-AzApiManagementCustomHostnameConfiguration -Hostname $gatewayHostname -HostnameType Proxy -PfxPath $gatewayCertPfxPath -PfxPassword $certPwd
# $portalHostnameConfig = New-AzApiManagementCustomHostnameConfiguration -Hostname $portalHostname -HostnameType DeveloperPortal -PfxPath $portalCertPfxPath -PfxPassword $certPortalPwd

# $apimService.ProxyCustomHostnameConfiguration = $proxyHostnameConfig
# $apimService.PortalCustomHostnameConfiguration = $portalHostnameConfig
# Set-AzApiManagement -InputObject $apimService

resource "azurerm_api_management" "internal" {
  location             = azurerm_resource_group.main.location
  name                 = local.apim_resource_name
  publisher_email      = "admin@contoso.com"
  publisher_name       = "Contoso"
  resource_group_name  = azurerm_resource_group.main.name
  sku_name             = "Developer_1"
  virtual_network_type = "Internal"

  hostname_configuration {
    proxy {
      host_name            = local.gateway_hostname
      certificate          = filebase64("certificates/gateway.pfx")
      certificate_password = "Password123$"
    }

    portal {
      host_name            = local.portal_hostname
      certificate          = filebase64("certificates/portal.pfx")
      certificate_password = "Password123$"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim.id
  }
}
