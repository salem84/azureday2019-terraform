variable "deployment_name" { }
variable "location" { }
variable "admin_user" { }
variable "admin_pass" { }
variable "tags" {
  type        = "map"
  description = "Default tags for all resources"

  default = {
    environment         = "production",
    version             = "1.0.0"
  }
}