##############################################################
# Root Variables
##############################################################

# ── General ─────────────────────────────────────────────────
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "prefix" {
  description = "Short prefix for all resource names (e.g. myapp)"
  type        = string
  validation {
    condition     = length(var.prefix) <= 10
    error_message = "prefix must be 10 characters or fewer."
  }
}

variable "environment" {
  description = "Deployment environment: dev, staging, or prod"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Additional tags to merge with common tags"
  type        = map(string)
  default     = {}
}

# ── Network ──────────────────────────────────────────────────
variable "vnet_address_space" {
  description = "Address space of the Virtual Network"
  type        = list(string)
}

variable "aks_subnet_prefixes" {
  description = "Address prefixes for AKS subnet"
  type        = list(string)
}

variable "frontend_subnet_prefixes" {
  description = "Address prefixes for Frontend / App Gateway subnet"
  type        = list(string)
}

variable "db_subnet_prefixes" {
  description = "Address prefixes for Database subnet"
  type        = list(string)
}

variable "dns_servers" {
  description = "Custom DNS servers for the VNet"
  type        = list(string)
  default     = []
}

# ── AKS ──────────────────────────────────────────────────────
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30.0"
}

variable "aks_sku_tier" {
  description = "AKS pricing tier: Free, Standard, Premium"
  type        = string
  default     = "Standard"
}

variable "aks_private_cluster" {
  description = "Whether the AKS cluster should be private"
  type        = bool
  default     = false
}

variable "acr_id" {
  description = "Azure Container Registry resource ID to attach"
  type        = string
  default     = ""
}

variable "dns_service_ip" {
  description = "IP for Kubernetes DNS service"
  type        = string
  default     = "10.100.0.10"
}

variable "service_cidr" {
  description = "CIDR for Kubernetes services"
  type        = string
  default     = "10.100.0.0/16"
}

variable "enable_monitoring" {
  description = "Enable Log Analytics monitoring"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

variable "system_node_pool" {
  description = "System node pool configuration"
  type = object({
    vm_size             = string
    node_count          = number
    min_count           = number
    max_count           = number
    enable_auto_scaling = bool
    os_disk_size_gb     = number
  })
}

variable "user_node_pool" {
  description = "User node pool configuration"
  type = object({
    vm_size             = string
    node_count          = number
    min_count           = number
    max_count           = number
    enable_auto_scaling = bool
    os_disk_size_gb     = number
  })
}

# ── Frontend ─────────────────────────────────────────────────
variable "availability_zones" {
  description = "Availability zones for zone-redundant resources"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "waf_mode" {
  description = "WAF mode: Detection or Prevention"
  type        = string
  default     = "Prevention"
}

variable "appgw_min_capacity" {
  description = "AppGW minimum autoscale instances"
  type        = number
  default     = 2
}

variable "appgw_max_capacity" {
  description = "AppGW maximum autoscale instances"
  type        = number
  default     = 10
}

variable "backend_fqdns" {
  description = "Backend FQDNs for AppGW (AKS ingress IPs/hostnames)"
  type        = list(string)
  default     = []
}

variable "health_probe_path" {
  description = "Health probe HTTP path"
  type        = string
  default     = "/health"
}

variable "ssl_certificate_name" {
  description = "SSL certificate name in Key Vault"
  type        = string
  default     = ""
}

variable "ssl_key_vault_secret_id" {
  description = "Key Vault secret ID for SSL cert"
  type        = string
  default     = ""
}

variable "enable_cdn" {
  description = "Enable Azure CDN"
  type        = bool
  default     = false
}

variable "cdn_sku" {
  description = "CDN SKU"
  type        = string
  default     = "Standard_Microsoft"
}

# ── Database ──────────────────────────────────────────────────
variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16"
}

variable "db_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "pgadmin"
}

variable "db_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "db_sku_name" {
  description = "PostgreSQL SKU"
  type        = string
  default     = "GP_Standard_D4s_v3"
}

variable "db_storage_mb" {
  description = "PostgreSQL storage in MB"
  type        = number
  default     = 65536
}

variable "db_auto_grow" {
  description = "Enable storage auto-grow"
  type        = bool
  default     = true
}

variable "db_backup_retention_days" {
  description = "Backup retention days"
  type        = number
  default     = 7
}

variable "db_geo_redundant_backup" {
  description = "Enable geo-redundant backup"
  type        = bool
  default     = false
}

variable "db_enable_ha" {
  description = "Enable zone-redundant high availability"
  type        = bool
  default     = false
}

variable "db_primary_zone" {
  description = "Primary availability zone"
  type        = string
  default     = "1"
}

variable "db_standby_zone" {
  description = "Standby availability zone for HA"
  type        = string
  default     = "2"
}

variable "db_name" {
  description = "Primary database name"
  type        = string
  default     = "appdb"
}

variable "additional_databases" {
  description = "Additional databases to create"
  type        = list(string)
  default     = []
}

variable "db_server_configurations" {
  description = "PostgreSQL server configuration parameters"
  type        = map(string)
  default     = {}
}
