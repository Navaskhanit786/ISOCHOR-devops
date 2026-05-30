##############################################################
# Module: Database
# Description: Azure Database for PostgreSQL Flexible Server
#              with high availability, backups, private networking
##############################################################

resource "azurerm_resource_group" "database" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                          = "${var.prefix}-postgres"
  resource_group_name           = azurerm_resource_group.database.name
  location                      = azurerm_resource_group.database.location
  version                       = var.postgres_version
  delegated_subnet_id           = var.db_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = false
  administrator_login           = var.admin_username
  administrator_password        = var.admin_password
  sku_name                      = var.sku_name
  storage_mb                    = var.storage_mb
  auto_grow_enabled             = var.auto_grow_enabled
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup
  zone                          = var.primary_zone
  tags                          = var.tags

  dynamic "high_availability" {
    for_each = var.enable_high_availability ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = var.standby_zone
    }
  }

  maintenance_window {
    day_of_week  = 0   # Sunday
    start_hour   = 2
    start_minute = 0
  }

  authentication {
    active_directory_auth_enabled = var.enable_aad_auth
    password_auth_enabled         = true
    tenant_id                     = var.enable_aad_auth ? var.aad_tenant_id : null
  }

  lifecycle {
    ignore_changes = [zone, high_availability[0].standby_availability_zone]
  }

  depends_on = [var.private_dns_zone_id]
}

# Default database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "utf8"

  lifecycle {
    prevent_destroy = false
  }
}

# Additional databases
resource "azurerm_postgresql_flexible_server_database" "extra" {
  for_each  = toset(var.additional_databases)
  name      = each.value
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# Server configurations (tuning)
resource "azurerm_postgresql_flexible_server_configuration" "configs" {
  for_each  = var.server_configurations
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = each.value
}

# Diagnostic settings -> Log Analytics
resource "azurerm_monitor_diagnostic_setting" "postgres" {
  count                      = var.log_analytics_workspace_id != "" ? 1 : 0
  name                       = "${var.prefix}-postgres-diag"
  target_resource_id         = azurerm_postgresql_flexible_server.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "PostgreSQLLogs"
  }

  enabled_log {
    category = "PostgreSQLFlexSessions"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
