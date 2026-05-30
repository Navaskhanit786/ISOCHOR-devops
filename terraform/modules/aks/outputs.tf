##############################################################
# Module: AKS - Outputs
##############################################################

output "cluster_id" {
  description = "Resource ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "kube_config_raw" {
  description = "Raw kubeconfig for the AKS cluster (sensitive)"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "host" {
  description = "Kubernetes API server hostname"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
  sensitive   = true
}

output "client_certificate" {
  description = "Client certificate for authentication"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Client key for authentication"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "identity_principal_id" {
  description = "Principal ID of the AKS managed identity"
  value       = azurerm_user_assigned_identity.aks.principal_id
}

output "identity_client_id" {
  description = "Client ID of the AKS managed identity"
  value       = azurerm_user_assigned_identity.aks.client_id
}

output "node_resource_group" {
  description = "Name of the auto-generated node resource group"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace (if enabled)"
  value       = var.enable_monitoring ? azurerm_log_analytics_workspace.aks[0].id : null
}
