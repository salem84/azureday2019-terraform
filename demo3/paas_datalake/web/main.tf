provider "azurerm" {
  version = ">= 1.1.0"
}

resource "azurerm_app_service_plan" "m_apps_serviceplan" {
  name                = "${var.serviceplan_name}-${var.serviceplan_sku_size}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  sku {
    tier = "${var.serviceplan_sku_tier}"
    size = "${var.serviceplan_sku_size}"
  }

   tags = "${var.tags}"
}


resource "azurerm_application_insights" "app_insight" {
  name                = "${var.webapp_name}-appinsight"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"
  application_type    = "Web"
}

# WEB APP
resource "azurerm_app_service" "m_apps_webapp" {
  name                = "${var.webapp_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"
  app_service_plan_id = "${azurerm_app_service_plan.m_apps_serviceplan.id}"
  https_only = true

  app_settings = {
    "STORAGE_CONNECTIONSTRING" = "${var.storage_connection_string}"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.app_insight.instrumentation_key}"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${var.sql_database_name},1433;Initial Catalog=${var.sql_server_domain_name};Persist Security Info=False;User ID=${var.sql_user};Password=${var.sql_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }

   tags = "${var.tags}"
}

# resource "azurerm_web_application_firewall_policy" "waf" {
#   name                = "${var.webapp_name}-waf"
#   location            = "${var.location}"
#   resource_group_name = "${var.resource_group}"

#   custom_rules {
#     name      = "Rule1"
#     priority  = 1
#     rule_type = "MatchRule"

#     match_conditions {
#       match_variables {
#         variable_name = "RemoteAddr"
#       }

#       operator           = "IPMatch"
#       negation_condition = false
#       match_values       = ["192.168.1.0/24", "10.0.0.0/24"]
#     }

#     action = "Block"
#   }
# }