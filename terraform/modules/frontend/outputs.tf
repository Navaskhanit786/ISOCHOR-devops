##############################################################
# Module: Frontend - Outputs
##############################################################

output "appgw_id" {
  description = "Resource ID of the Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "appgw_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.appgw.name
}

output "public_ip_address" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.appgw.ip_address
}

output "public_ip_fqdn" {
  description = "FQDN of the Application Gateway public IP"
  value       = azurerm_public_ip.appgw.fqdn
}

output "waf_policy_id" {
  description = "Resource ID of the WAF policy"
  value       = azurerm_web_application_firewall_policy.appgw.id
}

output "appgw_identity_principal_id" {
  description = "Principal ID of the Application Gateway managed identity"
  value       = azurerm_user_assigned_identity.appgw.principal_id
}

output "cdn_endpoint_hostname" {
  description = "CDN endpoint hostname (if CDN is enabled)"
  value       = var.enable_cdn ? azurerm_cdn_endpoint.frontend[0].host_name : null
}

output "backend_address_pool_id" {
  description = "ID of the backend address pool (used by AKS Ingress integration)"
  value       = tolist(azurerm_application_gateway.appgw.backend_address_pool)[0].id
}
