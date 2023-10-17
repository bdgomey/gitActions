terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.76.0"
    }
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "skillstorm"
    workspaces {
      prefix = "conoco-"
    }
  }
}

provider "azurerm" {
  features {
    
  }
}