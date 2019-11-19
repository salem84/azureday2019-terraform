variable "deployment_name" { }
variable "location" { }
variable "sqlserver_edition" { }
variable "serviceplan_sku_tier" { }
variable "serviceplan_sku_size" { }
variable "webapp_name" { }
variable "tags" {
  type        = "map"
  description = "Default tags for all resources"

  default = {
    environment         = "production",
    version             = "0.0.1"
  }
}

variable "sqlserver_pass" { }
variable "sqlserver_user" { }