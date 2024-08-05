provider "azurerm" {
  features {}

  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

}

resource "azurerm_resource_group" "example" {
  name     = "inchcape-rg"
  location = "West Europe"
}

resource "azurerm_service_plan" "example" {
  name                = "inchcape-asp"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "example" {
  name                = "inchcape-app"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  service_plan_id     = azurerm_service_plan.example.id

  site_config {
    app_command_line = "node src/index.js"
    always_on        = false
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "3000"
  }

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = all
  }
}
