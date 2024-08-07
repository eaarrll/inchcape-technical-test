provider "azurerm" {
  features = {}
  
  client_id       = "32ca3f9b-7759-4eae-989b-e6afd97aa5cc" 
  client_secret   = "i9R8Q~Geo-5WdcyD9LQhAJDba_gMRcweGAw6eaYq"
  tenant_id       = "448a85c3-3457-421d-98bb-a064ea7a8d8c"
  subscription_id = "d2363feb-a5e7-4392-819e-69ddc191b41c"
}

terraform {
  required_version = ">= 0.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
  }
}
