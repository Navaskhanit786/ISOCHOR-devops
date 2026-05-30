##############################################################
# Module: Network - Outputs
##############################################################

output "resource_group_name" {
  description = "Name of the network resource group"
  value       = azurerm_resource_group.network.name
}

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks.id
}

output "frontend_subnet_id" {
  description = "ID of the Frontend subnet"
  value       = azurerm_subnet.frontend.id
}

output "db_subnet_id" {
  description = "ID of the Database subnet"
  value       = azurerm_subnet.database.id
}

output "postgres_private_dns_zone_id" {
  description = "ID of the Private DNS Zone for PostgreSQL"
  value       = azurerm_private_dns_zone.postgres.id
}

output "postgres_private_dns_zone_name" {
  description = "Name of the Private DNS Zone for PostgreSQL"
  value       = azurerm_private_dns_zone.postgres.name
}
