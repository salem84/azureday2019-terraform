provider "azurerm" {
  version = ">= 1.1.0"
}
resource "azurerm_sql_server" "db_server" {
  name                         = "${var.database_server_name}-sql"
  resource_group_name          = "${var.resource_group}"
  location                     = "${var.location}"
  version                      = "12.0"
  administrator_login          = "${var.sqlserver_user}"
  administrator_login_password = "${var.sqlserver_pass}"

  tags = "${var.tags}"
}

resource "azurerm_sql_database" "db_instance" {
  name                = "${var.database_name}"
  resource_group_name = "${var.resource_group}"
  location            = "${var.location}"
  server_name         = "${azurerm_sql_server.db_server.name}"
  edition = "${var.sqlserver_edition}"

  tags = "${var.tags}"
}


resource "azurerm_storage_account" "storage" {
  name                     = "${var.storage_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_storage_container" "container" {
  name                  = "templates"
  # resource_group_name   = "${azurerm_resource_group.test.name}"
  storage_account_name  = "${azurerm_storage_account.storage.name}"
  container_access_type = "private"
}

resource "azurerm_storage_blob" "blob" {
  name                   = "template1.xlsx"
  # resource_group_name    = "${var.resource_group}"
  storage_account_name   = "${azurerm_storage_account.storage.name}"
  storage_container_name = "${azurerm_storage_container.container.name}"
  type                   = "Block"
  #source                 = "some-local-file.zip"
}

resource "azurerm_storage_queue" "queue" {
  name                 = "queue-triggers"
  # resource_group_name  = "${var.resource_group}"
  storage_account_name = "${azurerm_storage_account.storage.name}"
}

resource "azurerm_storage_table" "t-logs" {
  name                 = "logs"
  # resource_group_name  = "${var.resource_group}"
  storage_account_name = "${azurerm_storage_account.storage.name}"
}

resource "azurerm_storage_table" "t-configuration" {
  name                 = "configuration"
  # resource_group_name  = "${var.resource_group}"
  storage_account_name = "${azurerm_storage_account.storage.name}"
}