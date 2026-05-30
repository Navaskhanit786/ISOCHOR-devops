##############################################################
# Root Configuration
# Wires together: network -> aks -> frontend -> database
##############################################################

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Uncomment and configure for remote state (recommended for teams)
  # backend "azurerm" {
  #   resource_group_name  = "rg-tfstate"
  #   storage_account_name = "stterraformstate"
  #   container_name       = "tfstate"
  #   key                  = "dev/terraform.tfstate"
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = var.subscription_id
}

# ── Network Module ──────────────────────────────────────────
module "network" {
  source = "../../modules/network"

  prefix               = var.prefix
  resource_group_name  = "${var.prefix}-rg-network-${var.environment}"
  location             = var.location
  vnet_address_space   = var.vnet_address_space
  aks_subnet_prefixes  = var.aks_subnet_prefixes
  frontend_subnet_prefixes = var.frontend_subnet_prefixes
  db_subnet_prefixes   = var.db_subnet_prefixes
  dns_servers          = var.dns_servers
  tags                 = local.common_tags
}

# ── AKS Module ──────────────────────────────────────────────
module "aks" {
  source = "../../modules/aks"

  prefix               = var.prefix
  resource_group_name  = "${var.prefix}-rg-aks-${var.environment}"
  location             = var.location
  environment          = var.environment
  kubernetes_version   = var.kubernetes_version
  sku_tier             = var.aks_sku_tier
  private_cluster_enabled = var.aks_private_cluster
  aks_subnet_id        = module.network.aks_subnet_id
  acr_id               = var.acr_id
  dns_service_ip       = var.dns_service_ip
  service_cidr         = var.service_cidr
  enable_monitoring    = var.enable_monitoring
  log_retention_days   = var.log_retention_days
  system_node_pool     = var.system_node_pool
  user_node_pool       = var.user_node_pool
  tags                 = local.common_tags

  depends_on = [module.network]
}

# ── Frontend Module ─────────────────────────────────────────
module "frontend" {
  source = "../../modules/frontend"

  prefix                  = var.prefix
  resource_group_name     = "${var.prefix}-rg-frontend-${var.environment}"
  location                = var.location
  frontend_subnet_id      = module.network.frontend_subnet_id
  availability_zones      = var.availability_zones
  waf_mode                = var.waf_mode
  appgw_min_capacity      = var.appgw_min_capacity
  appgw_max_capacity      = var.appgw_max_capacity
  backend_fqdns           = var.backend_fqdns
  health_probe_path       = var.health_probe_path
  ssl_certificate_name    = var.ssl_certificate_name
  ssl_key_vault_secret_id = var.ssl_key_vault_secret_id
  enable_cdn              = var.enable_cdn
  cdn_sku                 = var.cdn_sku
  tags                    = local.common_tags

  depends_on = [module.network]
}

# ── Database Module ─────────────────────────────────────────
module "database" {
  source = "../../modules/database"

  prefix                     = var.prefix
  resource_group_name        = "${var.prefix}-rg-db-${var.environment}"
  location                   = var.location
  db_subnet_id               = module.network.db_subnet_id
  private_dns_zone_id        = module.network.postgres_private_dns_zone_id
  postgres_version           = var.postgres_version
  admin_username             = var.db_admin_username
  admin_password             = var.db_admin_password
  sku_name                   = var.db_sku_name
  storage_mb                 = var.db_storage_mb
  auto_grow_enabled          = var.db_auto_grow
  backup_retention_days      = var.db_backup_retention_days
  geo_redundant_backup       = var.db_geo_redundant_backup
  enable_high_availability   = var.db_enable_ha
  primary_zone               = var.db_primary_zone
  standby_zone               = var.db_standby_zone
  database_name              = var.db_name
  additional_databases       = var.additional_databases
  server_configurations      = var.db_server_configurations
  log_analytics_workspace_id = var.enable_monitoring ? module.aks.log_analytics_workspace_id : ""
  tags                       = local.common_tags

  depends_on = [module.network, module.aks]
}

# ── Locals ──────────────────────────────────────────────────
locals {
  common_tags = merge(var.tags, {
    environment = var.environment
    managed_by  = "terraform"
    project     = var.prefix
  })
}
