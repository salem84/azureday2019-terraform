provider "azurerm" {
  version = ">= 1.1.0"
}
resource "azurerm_data_factory" "etl_df" {
  name                = "${var.etl_name}df"
  resource_group_name = "${var.resource_group}"
  location            = "${var.location}"
}

resource "azurerm_data_lake_store" "etl_datalake" {
  name                = "${var.etl_name}lake"
  resource_group_name = "${var.resource_group}"
  location            = "${var.location}"
}

resource "azurerm_data_lake_store_firewall_rule" "etl_datalake_fw" {
  name                = "office-ip-range"
  account_name        = "${azurerm_data_lake_store.etl_datalake.name}"
  resource_group_name = "${var.resource_group}"
  start_ip_address    = "1.2.3.4"
  end_ip_address      = "2.3.4.5"
}

resource "azurerm_data_lake_analytics_account" "etl_analytics" {
  name                = "${var.etl_name}analytics"
  resource_group_name = "${var.resource_group}"
  location            = "${var.location}"
  default_store_account_name = "${azurerm_data_lake_store.etl_datalake.name}"
}