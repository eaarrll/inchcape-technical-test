terraform {
  backend "azurerm" {
    resource_group_name   = "inchcape-rg"
    storage_account_name  = "inchcapesa"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"

    client_id             = var.client_id
    client_secret         = var.client_secret
    subscription_id       = var.subscription_id
    tenant_id             = var.tenant_id

  }
}

