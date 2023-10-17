resource "azurerm_resource_group" "main" {
  name = "terraform"
  location = "eastus"
}

resource "azurerm_resource_group" "main2" {
  location = "eastus"
  name = "terraform2"
}

###