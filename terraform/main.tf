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

# Application Gateway
resource "azurerm_application_gateway" "app_gateway" {
  name                = "inchcape-app-gateway-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.gateway_subnet.id
  }

  frontend_port {
    name = "frontend-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }

  backend_address_pool {
    name = "backend-address-pool-sea"
    fqdns = ["inchcape-app-sea-${var.environment}.azurewebsites.net"]
  }

  backend_address_pool {
    name = "backend-address-pool-br"
    fqdns = ["inchcape-app-br-${var.environment}.azurewebsites.net"]
  }

  backend_http_settings {
    name                  = "default-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-configuration"
    frontend_port_name             = "frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-address-pool-sea"
    backend_http_settings_name = "default-backend-http-settings"
  }

  request_routing_rule {
    name                       = "rule2"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-address-pool-br"
    backend_http_settings_name = "default-backend-http-settings"
  }

  tags = {
    environment = var.environment
  }

  depends_on = [azurerm_subnet.gateway_subnet]
}

resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                = "app-gateway-public-ip-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "app-gateway-vnet-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "default"
    address_prefix = "10.0.0.0/24"
  }
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "gateway-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Traffic Manager
resource "azurerm_traffic_manager_profile" "traffic_manager" {
  name                = "inchcape-tm-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  traffic_routing_method = "Performance"
  dns_config {
    relative_name = "inchcape-tm-${var.environment}"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/"
  }

  profile_status = "Enabled"
}

resource "azurerm_traffic_manager_external_endpoint" "sea_endpoint" {
  name                = "sea-endpoint"
  resource_group_name = azurerm_resource_group.rg.name
  profile_name        = azurerm_traffic_manager_profile.traffic_manager.name
  type                = "externalEndpoints"
  target              = azurerm_public_ip.app_gateway_public_ip.ip_address
  endpoint_location   = var.location_se
  priority            = 1
}

resource "azurerm_traffic_manager_external_endpoint" "br_endpoint" {
  name                = "br-endpoint"
  resource_group_name = azurerm_resource_group.rg.name
  profile_name        = azurerm_traffic_manager_profile.traffic_manager.name
  type                = "externalEndpoints"
  target              = azurerm_public_ip.app_gateway_public_ip.ip_address
  endpoint_location   = var.location_br
  priority            = 2
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
      # Remove unsupported notifications
      send_to_subscription_administrator    = false
      send_to_subscription_co_administrator = false
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
      # Remove unsupported notifications
      send_to_subscription_administrator    = false
      send_to_subscription_co_administrator = false
    }
  }
}
