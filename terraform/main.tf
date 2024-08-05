provider "azurerm" {
  features {}
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
    always_on = true
    linux_fx_version = "NODE|14-lts"
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
    ignore_changes = [
      site_config[0].scm_type
    ]
  }
}
