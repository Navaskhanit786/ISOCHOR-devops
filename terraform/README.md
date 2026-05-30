# Terraform Infrastructure — AKS Platform

Production-ready Terraform modules for deploying a full application platform on Azure.

## Architecture

```
environments/dev/
├── main.tf          # Root — wires all modules
├── variables.tf     # All input variables
├── outputs.tf       # Key outputs
├── dev.tfvars       # Dev environment values
└── prod.tfvars      # Production environment values

modules/
├── network/         # VNet, Subnets, NSGs, Private DNS
├── aks/             # AKS cluster, node pools, monitoring
├── frontend/        # Application Gateway + WAF, CDN
└── database/        # PostgreSQL Flexible Server
```

## Module Overview

| Module | Resources |
|---|---|
| **network** | VNet, 3 subnets (AKS/Frontend/DB), NSGs, Private DNS Zone |
| **aks** | AKS cluster, system + user node pools, managed identity, Log Analytics |
| **frontend** | Application Gateway (WAF v2), Public IP, optional Azure CDN |
| **database** | PostgreSQL Flexible Server, databases, private networking |

## Prerequisites

- Terraform >= 1.7.0
- Azure CLI authenticated (`az login`)
- Contributor + User Access Administrator on target subscription

## Quick Start

```bash
cd environments/dev

# Initialise providers and modules
terraform init

# Preview changes
terraform plan -var-file="dev.tfvars"

# Apply
terraform apply -var-file="dev.tfvars"

# Destroy
terraform destroy -var-file="dev.tfvars"
```

## Passing Secrets Safely

Never commit passwords to `.tfvars`. Use environment variables instead:

```bash
export TF_VAR_db_admin_password="SuperSecretP@ss!"
terraform apply -var-file="dev.tfvars"
```

Or with Azure Key Vault + a CI/CD pipeline:

```bash
DB_PASS=$(az keyvault secret show --name db-admin-password --vault-name my-kv --query value -o tsv)
terraform apply -var-file="prod.tfvars" -var="db_admin_password=$DB_PASS"
```

## Remote State (Recommended for Teams)

Uncomment the `backend "azurerm"` block in `main.tf` and create the storage account:

```bash
az group create -n rg-tfstate -l eastus
az storage account create -n stterraformstate -g rg-tfstate --sku Standard_LRS
az storage container create -n tfstate --account-name stterraformstate
```

## Module Dependencies

```
network  ──►  aks
         └──►  frontend
         └──►  database  ◄── aks (log analytics workspace id)
```

## Useful Outputs

```bash
# Get kubeconfig
terraform output -raw aks_kube_config > ~/.kube/config-dev

# Get AppGW public IP
terraform output appgw_public_ip

# Get Postgres FQDN
terraform output postgres_fqdn
```
