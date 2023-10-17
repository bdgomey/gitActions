terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.76.0"
    }
  }
  backend "azurerm" {
  resource_group_name  = "bjgomes"
  storage_account_name = "terraformbjgomes"
  container_name       = "tfstate"
  key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    
  }
}