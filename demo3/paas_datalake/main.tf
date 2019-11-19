provider "azurerm" {
  version = "=1.35.0"
}

terraform {
    backend "azurerm" {}
}

locals {
  resource_group         = "RG-${var.location}-${var.deployment_name}"
  database_server_name   = "${var.deployment_name}-dbserver"
  database_name          = "${var.deployment_name}"
  servicebus_name        = "${var.deployment_name}sb"
  serviceplan_name       = "${var.deployment_name}-plan"
  storage_name           = "${var.deployment_name}storage"
  etl_name               = "${var.deployment_name}etl"
}


resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_group}"
  location = "${var.location}"
}


module "module_datastorage" {
  source = "./data-storage"
  location             = "${var.location}"
  resource_group       = "${azurerm_resource_group.rg.name}"
  tags                 = "${var.tags}"
  
  database_server_name = "${local.database_server_name}"
  database_name        = "${local.database_name}"
  sqlserver_edition    = "${var.sqlserver_edition}"
  sqlserver_user       = "${var.sqlserver_user}"
  sqlserver_pass       = "${var.sqlserver_pass}"
  storage_name         = "${local.storage_name}"
}

module "module_etl" {
  source = "./etl"
  location             = "${var.location}"
  resource_group       = "${azurerm_resource_group.rg.name}"
  tags                 = "${var.tags}"

  etl_name             = "${local.etl_name}"
}

module "module_web" {
  source = "./web"

  location               = "${var.location}"
  resource_group         = "${azurerm_resource_group.rg.name}"
  tags                   = "${var.tags}"

  storage_connection_string = "${module.module_datastorage.storage_connection_string}"
  serviceplan_name       = "${local.serviceplan_name}"
  webapp_name            = "${var.webapp_name}"

  serviceplan_sku_tier   = "${var.serviceplan_sku_tier}"
  serviceplan_sku_size   = "${var.serviceplan_sku_size}"

  sql_database_name      = "${module.module_datastorage.sql_database_name}"
  sql_server_domain_name = "${module.module_datastorage.sql_server_domain_name}"
  sql_user               = "${module.module_datastorage.sql_user}"
  sql_password           = "${module.module_datastorage.sql_password}"
}