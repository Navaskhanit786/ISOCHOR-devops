##############################################################
# Module: Frontend
# Description: Azure Application Gateway + WAF, Public IP,
#              optional CDN, SSL termination
##############################################################

resource "azurerm_resource_group" "frontend" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Public IP for Application Gateway
resource "azurerm_public_ip" "appgw" {
  name                = "${var.prefix}-appgw-pip"
  location            = azurerm_resource_group.frontend.location
  resource_group_name = azurerm_resource_group.frontend.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.availability_zones
  tags                = var.tags
}

# WAF Policy
resource "azurerm_web_application_firewall_policy" "appgw" {
  name                = "${var.prefix}-waf-policy"
  resource_group_name = azurerm_resource_group.frontend.name
  location            = azurerm_resource_group.frontend.location
  tags                = var.tags

  policy_settings {
    enabled                     = true
    mode                        = var.waf_mode
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
    managed_rule_set {
      type    = "Microsoft_BotManagerRuleSet"
      version = "1.0"
    }
  }
}

# Application Gateway with WAF v2
resource "azurerm_application_gateway" "appgw" {
  name                = "${var.prefix}-appgw"
  location            = azurerm_resource_group.frontend.location
  resource_group_name = azurerm_resource_group.frontend.name
  zones               = var.availability_zones
  tags                = var.tags
  firewall_policy_id  = azurerm_web_application_firewall_policy.appgw.id

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = var.appgw_min_capacity
    max_capacity = var.appgw_max_capacity
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.frontend_subnet_id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  # Backend address pool -> AKS ingress
  backend_address_pool {
    name  = "aks-backend-pool"
    fqdns = var.backend_fqdns
  }

  backend_http_settings {
    name                  = "http-backend-settings"
    cookie_based_affinity = "Disabled"
    protocol              = "Http"
    port                  = 80
    request_timeout       = 60

    probe_name = "aks-health-probe"
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  # HTTPS listener (SSL termination at AppGW)
  dynamic "http_listener" {
    for_each = var.ssl_certificate_name != "" ? [1] : []
    content {
      name                           = "https-listener"
      frontend_ip_configuration_name = "frontend-ip-config"
      frontend_port_name             = "https-port"
      protocol                       = "Https"
      ssl_certificate_name           = var.ssl_certificate_name
    }
  }

  # HTTP -> HTTPS redirect
  dynamic "redirect_configuration" {
    for_each = var.ssl_certificate_name != "" ? [1] : []
    content {
      name                 = "http-to-https-redirect"
      redirect_type        = "Permanent"
      target_listener_name = "https-listener"
      include_path         = true
      include_query_string = true
    }
  }

  request_routing_rule {
    name                       = "http-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = var.ssl_certificate_name != "" ? "https-listener" : "http-listener"
    backend_address_pool_name  = "aks-backend-pool"
    backend_http_settings_name = "http-backend-settings"
    priority                   = 100
  }

  dynamic "request_routing_rule" {
    for_each = var.ssl_certificate_name != "" ? [1] : []
    content {
      name                        = "http-redirect-rule"
      rule_type                   = "Basic"
      http_listener_name          = "http-listener"
      redirect_configuration_name = "http-to-https-redirect"
      priority                    = 200
    }
  }

  probe {
    name                = "aks-health-probe"
    protocol            = "Http"
    path                = var.health_probe_path
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    host                = "127.0.0.1"
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificate_name != "" ? [1] : []
    content {
      name                = var.ssl_certificate_name
      key_vault_secret_id = var.ssl_key_vault_secret_id
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appgw.id]
  }

  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      http_listener,
      probe,
      request_routing_rule,
      tags["last-modified"],
    ]
  }
}

# Managed Identity for AppGW (Key Vault cert access)
resource "azurerm_user_assigned_identity" "appgw" {
  name                = "${var.prefix}-appgw-identity"
  resource_group_name = azurerm_resource_group.frontend.name
  location            = azurerm_resource_group.frontend.location
  tags                = var.tags
}

# Optional: Azure CDN Profile
resource "azurerm_cdn_profile" "frontend" {
  count               = var.enable_cdn ? 1 : 0
  name                = "${var.prefix}-cdn"
  location            = "global"
  resource_group_name = azurerm_resource_group.frontend.name
  sku                 = var.cdn_sku
  tags                = var.tags
}

resource "azurerm_cdn_endpoint" "frontend" {
  count               = var.enable_cdn ? 1 : 0
  name                = "${var.prefix}-cdn-endpoint"
  profile_name        = azurerm_cdn_profile.frontend[0].name
  location            = "global"
  resource_group_name = azurerm_resource_group.frontend.name
  tags                = var.tags

  origin_host_header = azurerm_public_ip.appgw.fqdn

  origin {
    name      = "appgw-origin"
    host_name = azurerm_public_ip.appgw.fqdn
  }

  delivery_rule {
    name  = "EnforceHTTPS"
    order = 1

    request_scheme_condition {
      operator     = "Equal"
      match_values = ["HTTP"]
    }

    url_redirect_action {
      redirect_type = "Found"
      protocol      = "Https"
    }
  }
}
