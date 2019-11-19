output "sql_database_name" {
    value = "${azurerm_sql_database.db_instance.name}"
}

output "sql_server_domain_name" {
  value = "${azurerm_sql_server.db_server.fully_qualified_domain_name}"
}

output "sql_user" {
  value = "${azurerm_sql_server.db_server.administrator_login}"
}

output "sql_password" {
  value = "${azurerm_sql_server.db_server.administrator_login_password}"
}

output "storage_connection_string" {
  value = "${azurerm_storage_account.storage.primary_connection_string}"
}
