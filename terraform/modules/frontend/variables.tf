##############################################################
# Module: Frontend - Variables
##############################################################

variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for frontend resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "frontend_subnet_id" {
  description = "ID of the subnet for the Application Gateway"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for zone-redundant resources"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "waf_mode" {
  description = "WAF mode: Detection or Prevention"
  type        = string
  default     = "Prevention"
  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "waf_mode must be Detection or Prevention."
  }
}

variable "appgw_min_capacity" {
  description = "Minimum number of Application Gateway instances (autoscale)"
  type        = number
  default     = 2
}

variable "appgw_max_capacity" {
  description = "Maximum number of Application Gateway instances (autoscale)"
  type        = number
  default     = 10
}

variable "backend_fqdns" {
  description = "List of backend FQDNs (AKS ingress controller IPs or hostnames)"
  type        = list(string)
  default     = []
}

variable "health_probe_path" {
  description = "HTTP path for the backend health probe"
  type        = string
  default     = "/health"
}

variable "ssl_certificate_name" {
  description = "Name of the SSL certificate stored in Key Vault (leave empty to disable HTTPS)"
  type        = string
  default     = ""
}

variable "ssl_key_vault_secret_id" {
  description = "Key Vault secret ID for the SSL certificate"
  type        = string
  default     = ""
}

variable "enable_cdn" {
  description = "Whether to deploy an Azure CDN in front of the Application Gateway"
  type        = bool
  default     = false
}

variable "cdn_sku" {
  description = "CDN SKU: Standard_Microsoft, Standard_Verizon, Premium_Verizon"
  type        = string
  default     = "Standard_Microsoft"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
