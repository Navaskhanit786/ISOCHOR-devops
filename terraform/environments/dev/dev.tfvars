##############################################################
# dev.tfvars — Sample values for the DEV environment
# Usage: terraform apply -var-file="dev.tfvars"
# NOTE: Do NOT commit db_admin_password to source control.
#       Use a secrets manager or CI/CD variable injection.
##############################################################

# ── General ─────────────────────────────────────────────────
subscription_id = "00000000-0000-0000-0000-000000000000"  # Replace
prefix          = "myapp"
environment     = "dev"
location        = "eastus"

tags = {
  owner      = "platform-team"
  cost-center = "engineering"
  repo       = "github.com/myorg/myapp-infra"
}

# ── Network ──────────────────────────────────────────────────
vnet_address_space       = ["10.0.0.0/8"]
aks_subnet_prefixes      = ["10.1.0.0/16"]
frontend_subnet_prefixes = ["10.2.0.0/24"]
db_subnet_prefixes       = ["10.3.0.0/24"]
dns_servers              = []   # Leave empty to use Azure DNS

# ── AKS ──────────────────────────────────────────────────────
kubernetes_version  = "1.30.0"
aks_sku_tier        = "Standard"
aks_private_cluster = false      # Set true for production

acr_id          = ""             # e.g. /subscriptions/.../resourceGroups/.../providers/Microsoft.ContainerRegistry/registries/myacr
dns_service_ip  = "10.100.0.10"
service_cidr    = "10.100.0.0/16"

enable_monitoring  = true
log_retention_days = 30

system_node_pool = {
  vm_size             = "Standard_D2s_v3"
  node_count          = 2
  min_count           = 1
  max_count           = 3
  enable_auto_scaling = true
  os_disk_size_gb     = 128
}

user_node_pool = {
  vm_size             = "Standard_D4s_v3"
  node_count          = 2
  min_count           = 2
  max_count           = 10
  enable_auto_scaling = true
  os_disk_size_gb     = 128
}

# ── Frontend ─────────────────────────────────────────────────
availability_zones = ["1", "2", "3"]
waf_mode           = "Detection"   # Switch to Prevention in prod
appgw_min_capacity = 1
appgw_max_capacity = 5
backend_fqdns      = []            # Populated after AKS ingress is deployed
health_probe_path  = "/health"

# HTTPS (leave empty to use HTTP-only in dev)
ssl_certificate_name    = ""
ssl_key_vault_secret_id = ""

# CDN (disabled in dev)
enable_cdn = false
cdn_sku    = "Standard_Microsoft"

# ── Database ──────────────────────────────────────────────────
postgres_version  = "16"
db_admin_username = "pgadmin"
db_admin_password = "Ch@ngeMe!Dev2025"   # Replace – use secrets manager in prod

db_sku_name              = "B_Standard_B2s"  # Burstable for dev (cheaper)
db_storage_mb            = 32768             # 32 GB
db_auto_grow             = true
db_backup_retention_days = 7
db_geo_redundant_backup  = false
db_enable_ha             = false             # Enable for prod
db_primary_zone          = "1"
db_standby_zone          = "2"

db_name              = "appdb"
additional_databases = ["analytics", "audit"]

db_server_configurations = {
  "max_connections"            = "100"
  "log_min_duration_statement" = "2000"   # Log queries > 2s in dev
  "log_connections"            = "on"
  "log_disconnections"         = "off"
}
