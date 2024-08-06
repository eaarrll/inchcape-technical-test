terraform {
  required_providers {
      azurerm = {
        source  = "hashicorp/azurerm"
        version = "=3.0.0"
      }
    }

  backend "azurerm" {
    resource_group_name   = "inchcape-rg"
    storage_account_name  = "inchcapesa"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}

