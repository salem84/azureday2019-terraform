provider "azurerm" {
  version = "=1.35.0"
}

terraform {
    backend "azurerm" {}
}

locals {
  resource_group         = "RG-${var.location}-${var.deployment_name}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_group}"
  location = "${var.location}"
}

module "network" {
    source              = "Azure/network/azurerm"
    version             = "~> 1.1.1"
    location            = "${var.location}"
    address_space       = "10.0.0.0/16"
    subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
    subnet_names        = ["subnet-backend", "subnet-db", "subnet-application", "subnet-frontend"]
    allow_rdp_traffic   = "true"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    tags                = "${var.tags}"
}

module "ad" {
    #source              = "Azure/compute/azurerm"
    source              = "./terraform-azurerm-compute"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    vm_hostname         = "${var.deployment_name}-ad"
    nb_public_ip        = "0"
    nb_instances        = "1"
    admin_username      = "${var.admin_user}"
    admin_password      = "${var.admin_pass}"
    vm_os_simple        = "WindowsServer"
    vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
    is_windows_image    = "true"
    # vm_os_publisher     = "MicrosoftWindowsServer"
    # vm_os_offer         = "WindowsServer"
    # vm_os_sku           = "2012-R2-Datacenter"
    vm_size             = "Standard_DS2_V2"
    tags                = "${var.tags}"
}

module "db" {
    #source              = "Azure/compute/azurerm"
    source              = "./terraform-azurerm-compute"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    vm_hostname         = "${var.deployment_name}-db"
    nb_public_ip        = "0"
    remote_port         = "3389"
    nb_instances        = "1"
    admin_username      = "${var.admin_user}"
    admin_password      = "${var.admin_pass}"
    vnet_subnet_id      = "${module.network.vnet_subnets[1]}"
    is_windows_image    = "true"
    vm_os_publisher     = "MicrosoftSQLServer"
    vm_os_offer         = "SQL2017-WS2016"
    vm_os_sku           = "Standard"
    vm_size             = "Standard_DS2_V2"
    tags                = "${var.tags}"
}

module "app" {
    #source              = "Azure/compute/azurerm"
    source              = "./terraform-azurerm-compute"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    vm_hostname         = "${var.deployment_name}-app"
    nb_public_ip        = "0"
    remote_port         = "3389"
    nb_instances        = "1"
    admin_username      = "${var.admin_user}"
    admin_password      = "${var.admin_pass}"
    vnet_subnet_id      = "${module.network.vnet_subnets[2]}"
    vm_os_publisher     = "MicrosoftSharePoint"
    vm_os_offer         = "MicrosoftSharePointServer"
    vm_os_sku           = "2016"
    is_windows_image    = "true"
    vm_size             = "Standard_DS2_V2"
    tags                = "${var.tags}"
}

module "wfe" {
    #source              = "Azure/compute/azurerm"
    source              = "./terraform-azurerm-compute"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    vm_hostname         = "${var.deployment_name}-fe"
    remote_port         = "3389"
    nb_public_ip        = "0"
    nb_instances        = "2"
    admin_username      = "${var.admin_user}"
    admin_password      = "${var.admin_pass}"
    vm_os_publisher     = "MicrosoftSharePoint"
    vm_os_offer         = "MicrosoftSharePointServer"
    vm_os_sku           = "2016"
    vnet_subnet_id      = "${module.network.vnet_subnets[3]}"
    is_windows_image    = "true"
    vm_size             = "Standard_DS2_V2"
    tags                = "${var.tags}"
}

module "lb_public_wfe" {
  #source              = "Azure/loadbalancer/azurerm"
  source                      = "./terraform-azurerm-loadbalancer"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  location                    = "${var.location}"
  prefix                      = "public-wfe"
  public_ip_reverse_fqdn      = "${var.deployment_name}-wfe"
  tags                        = "${var.tags}"
  lb_port = {
    http = ["80", "Tcp", "80"]
    https = ["443", "Tcp", "443"]
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "wfe1" {
  network_interface_id    = "${module.wfe.network_interface_ids[0]}"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = "${module.lb_public_wfe.azurerm_lb_backend_address_pool_id}"
}

resource "azurerm_network_interface_backend_address_pool_association" "wfe2" {
  network_interface_id    = "${module.wfe.network_interface_ids[1]}"
  ip_configuration_name   = "ipconfig2"
  backend_address_pool_id = "${module.lb_public_wfe.azurerm_lb_backend_address_pool_id}"
}

module "lb_public_app" {
  #source              = "Azure/loadbalancer/azurerm"
  source                      = "./terraform-azurerm-loadbalancer"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  location                    = "${var.location}"
  prefix                      = "public-app"
  public_ip_reverse_fqdn      = "${var.deployment_name}-app"
  tags                        = "${var.tags}"

  remote_port = {
    rdp = ["Tcp", "3389"]
  }
}

resource "azurerm_network_interface_nat_rule_association" "nat_nic_rule" {
  network_interface_id  = "${module.app.network_interface_ids[0]}"
  ip_configuration_name = "ipconfig1"
  nat_rule_id           = "${module.lb_public_app.azurerm_lb_nat_rule_ids[0]}"
}

output "public_ip_app_address" {
  value = "${module.lb_public_app.azurerm_public_ip_address}"
}

output "public_ip_app_fqdn" {
  value = "${module.lb_public_app.azurerm_public_ip_fqdn}"
}
