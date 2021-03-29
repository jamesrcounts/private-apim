# $gatewayHostname = "api.contoso.net"                 # API gateway host
# $portalHostname = "portal.contoso.net"               # API developer portal host
locals {
  gateway_hostname   = "api.jamesrcounts.com"
  portal_hostname    = "portal.jamesrcounts.com"
  apim_resource_name = "apim-${random_pet.fido.id}"
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

  identity {
    type = "SystemAssigned"
  }

  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim.id
  }
}

resource "azurerm_api_management_custom_domain" "domain" {
  depends_on = [
    azurerm_role_assignment.keyvault_secrets_user
  ]

  api_management_id = azurerm_api_management.internal.id

  proxy {
    host_name    = local.gateway_hostname
    key_vault_id = azurerm_key_vault_certificate.gateway.secret_id
  }

  developer_portal {
    host_name    = local.portal_hostname
    key_vault_id = azurerm_key_vault_certificate.portal.secret_id
  }
}