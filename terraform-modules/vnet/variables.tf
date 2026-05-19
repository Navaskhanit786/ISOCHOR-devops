variable "rg-name" {
  type        = string
  description = "resource group name"
  default     = "rg-devops-tf"
}

variable "cidr-for-vnet" {
  type    = list
  default = ["10.0.0.0/16"]
}

variable "cidr-for-public-subnet" {
  type    = list
  default = ["10.0.1.0/24"]
}

variable "cidr-for-bastion-subnet" {
  type    = list
  default = ["10.0.2.0/24"]
}

variable "cidr-for-firewall-subnet" {
  type    = list
  default = ["10.0.3.0/24"]
}
