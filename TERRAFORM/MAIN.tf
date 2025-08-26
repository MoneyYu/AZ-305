terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "group_postfix" {
  type = string
}

variable "user_name" {
  type    = string
  default = "demouser"
}

variable "user_passowrd" {
  type    = string
  default = "Azuredemo2020"
}

locals {
  group_name    = "AZ305-${var.group_postfix}"
  location      = "japaneast"
  random_str    = "cat"
  vm_size       = "Standard_B2s"
  lab01_name    = "lab01"
  lab02a_name    = "lab02a"
  lab02b_name    = "lab02b"
  lab02c_name    = "lab02c"
  lab02d_name    = "lab02d"
  lab03_name    = "lab03"
  lab04_name    = "lab04"
  lab05a_name   = "lab05a"
  lab05b_name   = "lab05b"
  lab06a_name   = "lab06a"
  lab06b_name   = "lab06b"
  lab06c_name   = "lab06c"
  lab06d_name   = "lab06d"
  lab07_name    = "lab07"
  lab08_name    = "lab08"
  lab09a_name   = "lab09a"
  lab09b_name   = "lab09b"
  lab09c_name   = "lab09c"
  lab09d_name   = "lab09d"
  lab10_name    = "lab10"
  lab11_name    = "lab11"
  user_name     = "demouser"
  user_passowrd = "Azuredemo2020"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "azurerm_client_config" "current" {}

resource "random_string" "rid" {
  length  = 3
  special = false
  numeric = false
  upper   = false
}

resource "random_integer" "rint" {
  min = 100
  max = 999
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "az305" {
  name     = local.group_name
  location = local.location

  tags = {
    environment = local.group_name
  }
}
