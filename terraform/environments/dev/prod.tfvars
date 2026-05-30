##############################################################
# prod.tfvars — Sample values for the PRODUCTION environment
# Usage: terraform apply -var-file="prod.tfvars"
# NOTE: db_admin_password should come from CI/CD secrets, NOT
#       this file. Remove or leave empty and inject at runtime.
##############################################################

# ── General ─────────────────────────────────────────────────
subscription_id = "00000000-0000-0000-0000-000000000000"  # Replace
prefix          = "myapp"
environment     = "prod"
location        = "eastus"

tags = {
  owner       = "platform-team"
  cost-center = "engineering"
  criticality = "high"
  repo        = "github.com/myorg/myapp-infra"
}

# ── Network ──────────────────────────────────────────────────
vnet_address_space       = ["10.0.0.0/8"]
aks_subnet_prefixes      = ["10.1.0.0/16"]
frontend_subnet_prefixes = ["10.2.0.0/24"]
db_subnet_prefixes       = ["10.3.0.0/24"]
dns_servers              = []

# ── AKS ──────────────────────────────────────────────────────
kubernetes_version  = "1.30.0"
aks_sku_tier        = "Standard"
aks_private_cluster = true       # Private cluster in prod

acr_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myapp-rg-shared/providers/Microsoft.ContainerRegistry/registries/myappprodacr"
dns_service_ip  = "10.100.0.10"
service_cidr    = "10.100.0.0/16"

enable_monitoring  = true
log_retention_days = 90

system_node_pool = {
  vm_size             = "Standard_D4s_v3"
  node_count          = 3
  min_count           = 3
  max_count           = 5
  enable_auto_scaling = true
  os_disk_size_gb     = 128
}

user_node_pool = {
  vm_size             = "Standard_D8s_v3"
  node_count          = 5
  min_count           = 3
  max_count           = 20
  enable_auto_scaling = true
  os_disk_size_gb     = 256
}

# ── Frontend ─────────────────────────────────────────────────
availability_zones = ["1", "2", "3"]
waf_mode           = "Prevention"
appgw_min_capacity = 2
appgw_max_capacity = 20
backend_fqdns      = []          # Populated via AKS ingress
health_probe_path  = "/health"

ssl_certificate_name    = "myapp-prod-tls"
ssl_key_vault_secret_id = "https://myapp-kv-prod.vault.azure.net/secrets/myapp-prod-tls"

enable_cdn = true
cdn_sku    = "Standard_Microsoft"

# ── Database ──────────────────────────────────────────────────
postgres_version  = "16"
db_admin_username = "pgadmin"
db_admin_password = ""           # Inject via CI/CD: TF_VAR_db_admin_password

db_sku_name              = "GP_Standard_D4s_v3"
db_storage_mb            = 131072    # 128 GB
db_auto_grow             = true
db_backup_retention_days = 35
db_geo_redundant_backup  = true
db_enable_ha             = true      # Zone-redundant HA for prod
db_primary_zone          = "1"
db_standby_zone          = "2"

db_name              = "appdb"
additional_databases = ["analytics", "audit"]

db_server_configurations = {
  "max_connections"            = "200"
  "shared_buffers"             = "512MB"
  "effective_cache_size"       = "1536MB"
  "maintenance_work_mem"       = "128MB"
  "wal_buffers"                = "32MB"
  "log_min_duration_statement" = "1000"
  "log_connections"            = "on"
  "log_disconnections"         = "on"
}
