variable "resource_group" { }
variable "location" { }
variable "sql_database_name" { }
variable "sql_server_domain_name" { }
variable "sql_user" { }
variable "sql_password" { }
variable "webapp_name" { }
variable "serviceplan_name" { }
variable "serviceplan_sku_tier" { }
variable "serviceplan_sku_size" { }
variable "storage_connection_string" { }
variable "tags" {
  type        = "map"
}