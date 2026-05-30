##############################################################
# Module: Database - Outputs
##############################################################

output "server_id" {
  description = "Resource ID of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.main.id
}

output "server_name" {
  description = "Name of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.main.name
}

output "server_fqdn" {
  description = "Fully qualified domain name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "database_name" {
  description = "Name of the primary application database"
  value       = azurerm_postgresql_flexible_server_database.main.name
}

output "admin_username" {
  description = "Administrator username"
  value       = azurerm_postgresql_flexible_server.main.administrator_login
  sensitive   = true
}

output "connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = "postgresql://${azurerm_postgresql_flexible_server.main.administrator_login}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${var.database_name}?sslmode=require"
  sensitive   = true
}

output "additional_database_names" {
  description = "Names of additionally created databases"
  value       = [for db in azurerm_postgresql_flexible_server_database.extra : db.name]
}
