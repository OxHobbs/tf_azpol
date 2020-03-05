variable "client_id" {}
variable "tenant_id" {}
variable "client_secret" {}
variable "subscription_id" {}

provider "azurerm" {
  version         = "=1.37.0"
  environment     = "usgovernment"
  client_id       = var.client_id
  tenant_id       = var.tenant_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
}


module "naas_governance" {
  source = "../../../modules/governance/naas_governance"

  management_group_id = "main-group"
  
  rg_tags = {
    "CostCenter" = "Default"
    "AppName"    = "Default"
    "TF"         = "terraform"
  }

  tags = {
    "ProjectCode" = "Default"
    "AppName"     = "Default"
    "environment" = "terraform"
    "Customer"    = "USAF"
    "Requestor"   = "adfsteam@usaf.gov"
  }

  allowed_managed_disk_skus = "Standard_LRS"
}
