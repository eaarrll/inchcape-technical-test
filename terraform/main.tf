# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "inchcape-rg-${var.environment}"
  location = var.location_se
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "inchcape-log-analytics-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Application Insights
resource "azurerm_application_insights" "ai" {
  name                = "inchcape-app-insights-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# App Service Plan in Southeast Asia
resource "azurerm_service_plan" "sea_asp" {
  name                = "inchcape-asp-sea-${var.environment}"
  location            = var.location_se
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "S1"
}

# App Service Plan in Brazil South
resource "azurerm_service_plan" "br_asp" {
  name                = "inchcape-asp-br-${var.environment}"
  location            = var.location_br
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "S1"
}

# Linux Web App in Southeast Asia
resource "azurerm_linux_web_app" "sea_app" {
  name                = "inchcape-app-sea-${var.environment}"
  location            = azurerm_service_plan.sea_asp.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.sea_asp.id

  site_config {
    app_command_line = "npm start"
    always_on        = true
    linux_fx_version = "NODE|18-lts"
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE  = "false"
    WEBSITES_PORT                        = "3000"
    WEBSITE_NODE_DEFAULT_VERSION         = "18"
    SCM_DO_BUILD_DURING_DEPLOYMENT       = "true"
    APPINSIGHTS_INSTRUMENTATIONKEY       = azurerm_application_insights.ai.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.ai.connection_string
    LOG_ANALYTICS_WORKSPACE_ID           = azurerm_log_analytics_workspace.law.workspace_id
  }

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = all
  }
}

# Linux Web App in Brazil South
resource "azurerm_linux_web_app" "br_app" {
  name                = "inchcape-app-br-${var.environment}"
  location            = azurerm_service_plan.br_asp.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.br_asp.id

  site_config {
    app_command_line = "npm start"
    always_on        = true
    linux_fx_version = "NODE|18-lts"
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE  = "false"
    WEBSITES_PORT                        = "3000"
    WEBSITE_NODE_DEFAULT_VERSION         = "18"
    SCM_DO_BUILD_DURING_DEPLOYMENT       = "true"
    APPINSIGHTS_INSTRUMENTATIONKEY       = azurerm_application_insights.ai.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.ai.connection_string
    LOG_ANALYTICS_WORKSPACE_ID           = azurerm_log_analytics_workspace.law.workspace_id
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

# Front Door
resource "azurerm_frontdoor" "frontdoor" {
  name                = "inchcape-frontdoor-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name

  routing_rule {
    name               = "routing-rule1"
    frontend_endpoints = ["frontend-endpoint1"]
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/*"]
    forwarding_configuration {
      forwarding_protocol = "HttpsOnly"
      backend_pool_name   = "backend-pool1"
    }
  }

  backend_pool {
    name                = "backend-pool1"
    load_balancing_name = "load-balancing-settings1"
    health_probe_name   = "health-probe-settings1"

    backend {
      host_header = "inchcape-app-sea-${var.environment}.azurewebsites.net"
      address     = "inchcape-app-sea-${var.environment}.azurewebsites.net"
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 50
    }

    backend {
      host_header = "inchcape-app-br-${var.environment}.azurewebsites.net"
      address     = "inchcape-app-br-${var.environment}.azurewebsites.net"
      http_port   = 80
      https_port  = 443
      priority    = 2
      weight      = 50
    }
  }

  backend_pool_health_probe {
    name     = "health-probe-settings1"
    protocol = "Https"
    path     = "/"
    interval_in_seconds = 30
  }

  backend_pool_load_balancing {
    name   = "load-balancing-settings1"
    sample_size     = 4
    successful_samples_required = 2
  }

  frontend_endpoint {
    name      = "frontend-endpoint1"
    host_name = "example-frontdoor-${var.environment}.azurefd.net"
  }

  tags = {
    environment = var.environment
  }
}

# Autoscale settings for the App Service Plan in Southeast Asia
resource "azurerm_monitor_autoscale_setting" "autoscale_sea" {
  name                = "autoscale-sea-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_service_plan.sea_asp.id

  profile {
    name = "defaultProfile"
    capacity {
      default = 1
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.sea_asp.id
        operator           = "GreaterThan"
        statistic          = "Average"
        threshold          = 75
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = "PT5M"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.sea_asp.id
        operator           = "LessThan"
        statistic          = "Average"
        threshold          = 25
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = "PT5M"
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
    }
  }
}

# Autoscale settings for the App Service Plan in Brazil South
resource "azurerm_monitor_autoscale_setting" "autoscale_br" {
  name                = "autoscale-br-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_service_plan.br_asp.id

  profile {
    name = "defaultProfile"
    capacity {
      default = 1
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.br_asp.id
        operator           = "GreaterThan"
        statistic          = "Average"
        threshold          = 75
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = "PT5M"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.br_asp.id
        operator           = "LessThan"
        statistic          = "Average"
        threshold          = 25
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = "PT5M"
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
    }
  }
}

