##############################################################
# Module: AKS - Variables
##############################################################

variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for AKS resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev / staging / prod)"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.30.0"
}

variable "sku_tier" {
  description = "AKS pricing tier: Free, Standard, or Premium"
  type        = string
  default     = "Standard"
}

variable "private_cluster_enabled" {
  description = "Whether the AKS API server should be private"
  type        = bool
  default     = false
}

variable "aks_subnet_id" {
  description = "ID of the subnet where AKS nodes will be deployed"
  type        = string
}

variable "acr_id" {
  description = "Resource ID of the Azure Container Registry to attach (leave empty to skip)"
  type        = string
  default     = ""
}

variable "dns_service_ip" {
  description = "IP address for the Kubernetes DNS service (must be within service_cidr)"
  type        = string
  default     = "10.100.0.10"
}

variable "service_cidr" {
  description = "CIDR range for Kubernetes services (must not overlap with VNet)"
  type        = string
  default     = "10.100.0.0/16"
}

variable "automatic_upgrade_channel" {
  description = "AKS auto-upgrade channel: none, patch, rapid, stable, node-image"
  type        = string
  default     = "stable"
}

variable "enable_monitoring" {
  description = "Enable OMS agent and Log Analytics workspace"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Log Analytics workspace data retention in days"
  type        = number
  default     = 30
}

variable "system_node_pool" {
  description = "Configuration for the system (critical addons) node pool"
  type = object({
    vm_size             = string
    node_count          = number
    min_count           = number
    max_count           = number
    enable_auto_scaling = bool
    os_disk_size_gb     = number
  })
  default = {
    vm_size             = "Standard_D2s_v3"
    node_count          = 2
    min_count           = 1
    max_count           = 3
    enable_auto_scaling = true
    os_disk_size_gb     = 128
  }
}

variable "user_node_pool" {
  description = "Configuration for the user (application workload) node pool"
  type = object({
    vm_size             = string
    node_count          = number
    min_count           = number
    max_count           = number
    enable_auto_scaling = bool
    os_disk_size_gb     = number
  })
  default = {
    vm_size             = "Standard_D4s_v3"
    node_count          = 2
    min_count           = 2
    max_count           = 10
    enable_auto_scaling = true
    os_disk_size_gb     = 128
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
