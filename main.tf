resource "azurerm_resource_group" "main" {
  name     = "terraform"
  location = "eastus"
}
# Create a virtual network

resource "azurerm_virtual_network" "main" {
  name                = "terraform-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Create a subnet

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Create a public IP address

resource "azurerm_public_ip" "main" {
  name                = "terraform-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
}

# Create a network interface

resource "azurerm_network_interface" "main" {
  name                = "terraform-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "terraform-ipconfig"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

#azure ubuntu VM

resource "azurerm_linux_virtual_machine" "main" {
  name                  = "myterraformvm"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = "standard_b2s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.main.id]
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("./id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  # custom_data = "ICAgICAgICAjIS9iaW4vYmFzaAoKICAgICAgICAjIFVwZGF0ZSBzeXN0ZW0gcGFja2FnZXMKICAgICAgICBhcHQtZ2V0IHVwZGF0ZSAteQogICAgICAgIGFwdC1nZXQgdXBncmFkZSAteQoKICAgICAgICAjIEluc3RhbGwgQXBhY2hlLCBNeVNRTCwgUEhQLCBhbmQgb3RoZXIgZGVwZW5kZW5jaWVzCiAgICAgICAgYXB0LWdldCBpbnN0YWxsIC15IGFwYWNoZTIgbXlzcWwtY2xpZW50IHBocCBwaHAtbXlzcWwgbGliYXBhY2hlMi1tb2QtcGhwIHBocC1jbGkgcGhwLWN1cmwgcGhwLWdkIHBocC1tYnN0cmluZyBwaHAteG1sIHBocC14bWxycGMKCiAgICAgICAgIyBFbmFibGUgQXBhY2hlIG1vZHVsZXMKICAgICAgICBzeXN0ZW1jdGwgcmVzdGFydCBhcGFjaGUyCgogICAgICAgICMgRG93bmxvYWQgYW5kIGV4dHJhY3QgV29yZFByZXNzCiAgICAgICAgY2QgL3Zhci93d3cvaHRtbAogICAgICAgIHdnZXQgaHR0cHM6Ly93b3JkcHJlc3Mub3JnL2xhdGVzdC50YXIuZ3oKICAgICAgICB0YXIgLXhmIGxhdGVzdC50YXIuZ3oKICAgICAgICBybSBsYXRlc3QudGFyLmd6CiAgICAgICAgY2hvd24gLVIgd3d3LWRhdGE6d3d3LWRhdGEgd29yZHByZXNzCgogICAgICAgICMgQ29uZmlndXJlIFdvcmRQcmVzcwogICAgICAgIGNwIC92YXIvd3d3L2h0bWwvd29yZHByZXNzL3dwLWNvbmZpZy1zYW1wbGUucGhwIC92YXIvd3d3L2h0bWwvd29yZHByZXNzL3dwLWNvbmZpZy5waHAKICAgICAgICBzZWQgLWkgXCJzL2RhdGFiYXNlX25hbWVfaGVyZS93b3JkcHJlc3MvZ1wiIC92YXIvd3d3L2h0bWwvd29yZHByZXNzL3dwLWNvbmZpZy5waHAKICAgICAgICBzZWQgLWkgXCJzL3VzZXJuYW1lX2hlcmUvYWRtaW4vZ1wiIC92YXIvd3d3L2h0bWwvd29yZHByZXNzL3dwLWNvbmZpZy5waHAKICAgICAgICBzZWQgLWkgXCJzL3Bhc3N3b3JkX2hlcmUvcGFzc3dvcmQxMjM0L2dcIiAvdmFyL3d3dy9odG1sL3dvcmRwcmVzcy93cC1jb25maWcucGhwCiAgICAgICAgc2VkIC1pIFwicy9sb2NhbGhvc3QvbG9jYWxob3N0cy9nXCIgL3Zhci93d3cvaHRtbC93b3JkcHJlc3Mvd3AtY29uZmlnLnBocAoKICAgICAgICBzeXN0ZW1jdGwgcmVzdGFydCBhcGFjaGUy"
}

# azurerm vm extension with a bash script

resource "azurerm_virtual_machine_extension" "main" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.main.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = jsonencode(
    {
      "script" : "IyEvYmluL2Jhc2hcblxuYXB0LWdldCB1cGRhdGUgLXlcbmFwdC1nZXQgdXBncmFkZSAteVxuYXB0LWdldCBpbnN0YWxsIC15IGFwYWNoZTIgbXlzcWwtY2xpZW50IHBocCBwaHAtbXlzcWwgbGliYXBhY2hlMi1tb2QtcGhwIHBocC1jbGkgcGhwLWN1cmwgcGhwLWdkIHBocC1tYnN0cmluZyBwaHAteG1sIHBocC14bWxycGNcbnN5c3RlbWN0bCByZXN0YXJ0IGFwYWNoZTJcbmNkIC92YXIvd3d3L2h0bWxcbndnZXQgaHR0cHM6Ly93b3JkcHJlc3Mub3JnL2xhdGVzdC50YXIuZ3pcbnRhciAteGYgbGF0ZXN0LnRhci5nelxucm0gbGF0ZXN0LnRhci5nelxuY2hvd24gLVIgd3d3LWRhdGE6d3d3LWRhdGEgd29yZHByZXNzXG5jcCAvdmFyL3d3dy9odG1sL3dvcmRwcmVzcy93cC1jb25maWctc2FtcGxlLnBocCAvdmFyL3d3dy9odG1sL3dvcmRwcmVzcy93cC1jb25maWcucGhwXG5zZWQgLWkgXCJzL2RhdGFiYXNlX25hbWVfaGVyZS93b3JkcHJlc3MvZ1wiIC92YXIvd3d3L2h0bWwvd29yZHByZXNzL3dwLWNvbmZpZy5waHBcbnNlZCAtaSBcInMvdXNlcm5hbWVfaGVyZS9hZG1pbi9nXCIgL3Zhci93d3cvaHRtbC93b3JkcHJlc3Mvd3AtY29uZmlnLnBocFxuc2VkIC1pIFwicy9wYXNzd29yZF9oZXJlL3Bhc3N3b3JkMTIzNC9nXCIgL3Zhci93d3cvaHRtbC93b3JkcHJlc3Mvd3AtY29uZmlnLnBocFxuc2VkIC1pIFwicy9sb2NhbGhvc3QvbG9jYWxob3N0cy9nXCIgL3Zhci93d3cvaHRtbC93b3JkcHJlc3Mvd3AtY29uZmlnLnBocFxuc3lzdGVtY3RsIHJlc3RhcnQgYXBhY2hlMg=="
  })
}
