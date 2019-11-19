provider "azurerm" {
  
}

terraform {
    backend "azurerm" {}
}

variable "prefix" {
  default = "azday19"
}

resource "azurerm_resource_group" "test" {
  name     = "RG-${var.prefix}"
  location = "Central US"
}

resource "azurerm_app_service_plan" "test" {
  name                = "${var.prefix}-appserviceplan"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "${var.prefix}-app-service"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  app_service_plan_id = "${azurerm_app_service_plan.test.id}"

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.test.instrumentation_key}"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.test.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.test.name}; User ID=${azurerm_sql_server.test.administrator_login}@[serverName];Password=${azurerm_sql_server.test.administrator_login_password};Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}


resource "azurerm_sql_server" "test" {
  name                         = "${var.prefix}-mysqlserver"
  resource_group_name          = "${azurerm_resource_group.test.name}"
  location                     = "${azurerm_resource_group.test.location}"
  version                      = "12.0"
  administrator_login          = "giorgio"
  administrator_login_password = "P@ssword.1"
}

resource "azurerm_sql_database" "test" {
  name                = "${var.prefix}-sqldatabase"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"
  server_name         = "${azurerm_sql_server.test.name}"
}

resource "azurerm_application_insights" "test" {
  name                = "${var.prefix}-appinsight"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"
  application_type    = "web"
}
