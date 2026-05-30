##############################################################
# Root Outputs
##############################################################

# ── Network ──────────────────────────────────────────────────
output "vnet_id" {
  description = "Virtual Network ID"
  value       = module.network.vnet_id
}

output "aks_subnet_id" {
  description = "AKS subnet ID"
  value       = module.network.aks_subnet_id
}

output "db_subnet_id" {
  description = "Database subnet ID"
  value       = module.network.db_subnet_id
}

# ── AKS ──────────────────────────────────────────────────────
output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = module.aks.cluster_name
}

output "aks_kube_config" {
  description = "Raw kubeconfig (sensitive)"
  value       = module.aks.kube_config_raw
  sensitive   = true
}

output "aks_identity_principal_id" {
  description = "AKS managed identity principal ID"
  value       = module.aks.identity_principal_id
}

# ── Frontend ─────────────────────────────────────────────────
output "appgw_public_ip" {
  description = "Application Gateway public IP"
  value       = module.frontend.public_ip_address
}

output "appgw_public_fqdn" {
  description = "Application Gateway public FQDN"
  value       = module.frontend.public_ip_fqdn
}

output "cdn_endpoint" {
  description = "CDN endpoint hostname (if enabled)"
  value       = module.frontend.cdn_endpoint_hostname
}

# ── Database ──────────────────────────────────────────────────
output "postgres_fqdn" {
  description = "PostgreSQL server FQDN"
  value       = module.database.server_fqdn
}

output "postgres_connection_string" {
  description = "PostgreSQL connection string (sensitive)"
  value       = module.database.connection_string
  sensitive   = true
}

output "primary_database_name" {
  description = "Primary database name"
  value       = module.database.database_name
}
