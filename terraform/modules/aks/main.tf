##############################################################
# Module: AKS (Azure Kubernetes Service)
# Description: AKS cluster with system + user node pools,
#              managed identity, RBAC, monitoring
##############################################################

resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Managed Identity for AKS
resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.prefix}-aks-identity"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  tags                = var.tags
}

# Role assignment: AKS identity -> Network Contributor on subnet
resource "azurerm_role_assignment" "aks_network" {
  scope                = var.aks_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# Container Registry (optional - attach if provided)
resource "azurerm_role_assignment" "aks_acr_pull" {
  count                = var.acr_id != "" ? 1 : 0
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# Log Analytics Workspace for AKS monitoring
resource "azurerm_log_analytics_workspace" "aks" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "${var.prefix}-aks-logs"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                      = "${var.prefix}-aks"
  location                  = azurerm_resource_group.aks.location
  resource_group_name       = azurerm_resource_group.aks.name
  dns_prefix                = "${var.prefix}-aks"
  kubernetes_version        = var.kubernetes_version
  private_cluster_enabled   = var.private_cluster_enabled
  sku_tier                  = var.sku_tier
  node_resource_group       = "${var.resource_group_name}-nodes"
  tags                      = var.tags

  # System node pool (critical system pods)
  default_node_pool {
    name                        = "system"
    node_count                  = var.system_node_pool.node_count
    min_count                   = var.system_node_pool.min_count
    max_count                   = var.system_node_pool.max_count
    enable_auto_scaling         = var.system_node_pool.enable_auto_scaling
    vm_size                     = var.system_node_pool.vm_size
    os_disk_size_gb             = var.system_node_pool.os_disk_size_gb
    os_disk_type                = "Managed"
    vnet_subnet_id              = var.aks_subnet_id
    only_critical_addons_enabled = true
    temporary_name_for_rotation  = "systemtmp"

    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
    }

    tags = var.tags
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # Azure CNI networking
  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
    dns_service_ip     = var.dns_service_ip
    service_cidr       = var.service_cidr
  }

  # RBAC with Azure AD
  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  # OMS Agent (monitoring)
  dynamic "oms_agent" {
    for_each = var.enable_monitoring ? [1] : []
    content {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks[0].id
    }
  }

  # Key Vault Secrets Provider
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Auto-upgrade channel
  automatic_upgrade_channel = var.automatic_upgrade_channel

  maintenance_window_auto_upgrade {
    frequency    = "Weekly"
    interval     = 1
    duration     = 4
    day_of_week  = "Sunday"
    utc_offset   = "+00:00"
    start_time   = "00:00"
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      kubernetes_version,
    ]
  }
}

# User node pool (application workloads)
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.user_node_pool.vm_size
  node_count            = var.user_node_pool.node_count
  min_count             = var.user_node_pool.min_count
  max_count             = var.user_node_pool.max_count
  enable_auto_scaling   = var.user_node_pool.enable_auto_scaling
  os_disk_size_gb       = var.user_node_pool.os_disk_size_gb
  vnet_subnet_id        = var.aks_subnet_id
  mode                  = "User"

  node_labels = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "workload"      = "application"
  }

  node_taints = ["workload=application:NoSchedule"]

  tags = var.tags

  lifecycle {
    ignore_changes = [node_count]
  }
}
