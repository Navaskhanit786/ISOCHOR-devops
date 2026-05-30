##############################################################
# Module: Network - Variables
##############################################################

variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for networking resources"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
}

variable "aks_subnet_prefixes" {
  description = "Address prefixes for the AKS subnet"
  type        = list(string)
}

variable "frontend_subnet_prefixes" {
  description = "Address prefixes for the Frontend / App Gateway subnet"
  type        = list(string)
}

variable "db_subnet_prefixes" {
  description = "Address prefixes for the Database subnet"
  type        = list(string)
}

variable "dns_servers" {
  description = "Custom DNS servers for the VNet (leave empty to use Azure default)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
