##############################################################
# Module: Database - Variables
##############################################################

variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for database resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "db_subnet_id" {
  description = "ID of the delegated subnet for PostgreSQL Flexible Server"
  type        = string
}

variable "private_dns_zone_id" {
  description = "ID of the private DNS zone for PostgreSQL"
  type        = string
}

variable "postgres_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"
  validation {
    condition     = contains(["14", "15", "16"], var.postgres_version)
    error_message = "postgres_version must be 14, 15, or 16."
  }
}

variable "admin_username" {
  description = "Administrator username for PostgreSQL"
  type        = string
  default     = "pgadmin"
}

variable "admin_password" {
  description = "Administrator password for PostgreSQL (use Key Vault in production)"
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "SKU name for PostgreSQL Flexible Server (e.g. GP_Standard_D4s_v3)"
  type        = string
  default     = "GP_Standard_D4s_v3"
}

variable "storage_mb" {
  description = "Storage size in MB (32768, 65536, 131072, 262144, 524288, 1048576)"
  type        = number
  default     = 65536
}

variable "auto_grow_enabled" {
  description = "Whether storage auto-grow is enabled"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Backup retention period in days (7–35)"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "backup_retention_days must be between 7 and 35."
  }
}

variable "geo_redundant_backup" {
  description = "Enable geo-redundant backups"
  type        = bool
  default     = false
}

variable "enable_high_availability" {
  description = "Enable zone-redundant high availability"
  type        = bool
  default     = false
}

variable "primary_zone" {
  description = "Availability zone for the primary server"
  type        = string
  default     = "1"
}

variable "standby_zone" {
  description = "Availability zone for the standby (HA) server"
  type        = string
  default     = "2"
}

variable "database_name" {
  description = "Name of the primary application database"
  type        = string
  default     = "appdb"
}

variable "additional_databases" {
  description = "List of additional databases to create"
  type        = list(string)
  default     = []
}

variable "server_configurations" {
  description = "Map of PostgreSQL server configuration parameters"
  type        = map(string)
  default = {
    "max_connections"           = "200"
    "shared_buffers"            = "256MB"
    "effective_cache_size"      = "768MB"
    "maintenance_work_mem"      = "64MB"
    "wal_buffers"               = "16MB"
    "log_min_duration_statement" = "1000"
    "log_connections"           = "on"
    "log_disconnections"        = "on"
  }
}

variable "enable_aad_auth" {
  description = "Enable Azure Active Directory authentication"
  type        = bool
  default     = false
}

variable "aad_tenant_id" {
  description = "Azure AD tenant ID (required when enable_aad_auth = true)"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings (leave empty to disable)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
