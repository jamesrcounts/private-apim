# $gipconfig = New-AzApplicationGatewayIPConfiguration -Name "gatewayIP01" -Subnet $appgatewaysubnetdata
# $fp01 = New-AzApplicationGatewayFrontendPort -Name "port01"  -Port 443
# $fipconfig01 = New-AzApplicationGatewayFrontendIPConfig -Name "frontend1" -PublicIPAddress $publicip
# $cert = New-AzApplicationGatewaySslCertificate -Name "cert01" -CertificateFile $gatewayCertPfxPath -Password $certPwd
# $certPortal = New-AzApplicationGatewaySslCertificate -Name "cert02" -CertificateFile $portalCertPfxPath -Password $certPortalPwd
# $listener = New-AzApplicationGatewayHttpListener -Name "listener01" -Protocol "Https" -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -SslCertificate $cert -HostName $gatewayHostname -RequireServerNameIndication true
# $portalListener = New-AzApplicationGatewayHttpListener -Name "listener02" -Protocol "Https" -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -SslCertificate $certPortal -HostName $portalHostname -RequireServerNameIndication true
# $apimprobe = New-AzApplicationGatewayProbeConfig -Name "apimproxyprobe" -Protocol "Https" -HostName $gatewayHostname -Path "/status-0123456789abcdef" -Interval 30 -Timeout 120 -UnhealthyThreshold 8
# $apimPortalProbe = New-AzApplicationGatewayProbeConfig -Name "apimportalprobe" -Protocol "Https" -HostName $portalHostname -Path "/internal-status-0123456789abcdef" -Interval 60 -Timeout 300 -UnhealthyThreshold 8
# $authcert = New-AzApplicationGatewayAuthenticationCertificate -Name "whitelistcert1" -CertificateFile $gatewayCertCerPath
# $apimPoolSetting = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolSetting" -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimprobe -AuthenticationCertificates $authcert -RequestTimeout 180
# $apimPoolPortalSetting = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolPortalSetting" -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimPortalProbe -AuthenticationCertificates $authcert -RequestTimeout 180
# $apimProxyBackendPool = New-AzApplicationGatewayBackendAddressPool -Name "apimbackend" -BackendIPAddresses $apimService.PrivateIPAddresses[0]
# $rule01 = New-AzApplicationGatewayRequestRoutingRule -Name "rule1" -RuleType Basic -HttpListener $listener -BackendAddressPool $apimProxyBackendPool -BackendHttpSettings $apimPoolSetting
# $rule02 = New-AzApplicationGatewayRequestRoutingRule -Name "rule2" -RuleType Basic -HttpListener $portalListener -BackendAddressPool $apimProxyBackendPool -BackendHttpSettings $apimPoolPortalSetting
# $sku = New-AzApplicationGatewaySku -Name "WAF_Medium" -Tier "WAF" -Capacity 2
# $config = New-AzApplicationGatewayWebApplicationFirewallConfiguration -Enabled $true -FirewallMode "Prevention"
locals {
  application_gateway_name       = "agw-${local.project}"
  backend_address_pool_name      = "${local.application_gateway_name}-beap"
  frontend_port_name             = "${local.application_gateway_name}-feport"
  frontend_ip_configuration_name = "${local.application_gateway_name}-feip"
  http_setting_name              = "${local.application_gateway_name}-be-htst"
  listener_name                  = "${local.application_gateway_name}-httplstn"
  request_routing_rule_name      = "${local.application_gateway_name}-rqrt"
  redirect_configuration_name    = "${local.application_gateway_name}-rdrcfg"

  agw_listeners = {
    gateway = {
      certificate = azurerm_key_vault_certificate.apim["gateway"].secret_id
      hostname    = local.gateway_hostname
      path        = "/status-0123456789abcdef"
      interval    = 30
      timeout     = 120
      threshold   = 8
    }
    portal = {
      certificate = azurerm_key_vault_certificate.apim["portal"].secret_id
      hostname    = local.portal_hostname
      path        = "/internal-status-0123456789abcdef"
      interval    = 60
      timeout     = 300
      threshold   = 8
    }
  }
}

resource "azurerm_application_gateway" "agw" {
  depends_on = [
    azurerm_role_assignment.keyvault_secrets_user
  ]

  name                = local.application_gateway_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.tags

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = azurerm_api_management.internal.private_ip_addresses
  }

  dynamic "backend_http_settings" {
    for_each = local.agw_listeners

    content {
      cookie_based_affinity = "Disabled"
      name                  = backend_http_settings.key
      path                  = "/"
      port                  = 443
      probe_name            = backend_http_settings.key
      protocol              = "Https"
      request_timeout       = 180
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw.id]
  }

  dynamic "probe" {
    for_each = local.agw_listeners

    content {
      host                = probe.value.hostname
      interval            = probe.value.interval
      name                = probe.key
      path                = probe.value.path
      protocol            = "Https"
      timeout             = probe.value.timeout
      unhealthy_threshold = probe.value.threshold
    }
  }

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "${local.application_gateway_name}-ip-01"
    subnet_id = azurerm_subnet.agw.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.agw.id
  }

  dynamic "http_listener" {
    for_each = local.agw_listeners

    content {
      frontend_ip_configuration_name = local.frontend_ip_configuration_name
      frontend_port_name             = local.frontend_port_name
      host_name                      = http_listener.value.hostname
      name                           = http_listener.key
      protocol                       = "Https"
      require_sni                    = true
      ssl_certificate_name           = http_listener.key
    }
  }

  dynamic "request_routing_rule" {
    for_each = local.agw_listeners

    content {
      name                       = request_routing_rule.key
      rule_type                  = "Basic"
      http_listener_name         = request_routing_rule.key
      backend_address_pool_name  = local.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.key
    }
  }

  dynamic "ssl_certificate" {
    for_each = local.agw_listeners
    content {
      name                = ssl_certificate.key
      key_vault_secret_id = ssl_certificate.value.certificate
    }
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S"
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.1"
  }
}

resource "azurerm_user_assigned_identity" "agw" {
  location            = azurerm_resource_group.main.location
  name                = local.application_gateway_name
  resource_group_name = azurerm_resource_group.main.name
}