resource "azurerm_resource_group" "main" {
  name = "terraform"
  location = "eastus"
}


#azure ubuntu VM

resource "azurerm_linux_virtual_machine" "main" {
  name                = "myterraformvm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.main.id]
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:/Users/brian/.ssh/id_rsa.pub")
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
}

# azurerm vm extension with a bash script

resource "azurerm_virtual_machine_extension" "main" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.main.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
      "script": "  
        #!/bin/bash

        # Update system packages
        apt-get update -y
        apt-get upgrade -y

        # Install Apache, MySQL, PHP, and other dependencies
        apt-get install -y apache2 mysql-client php php-mysql libapache2-mod-php php-cli php-curl php-gd php-mbstring php-xml php-xmlrpc

        # Enable Apache modules
        systemctl restart apache2

        # Download and extract WordPress
        cd /var/www/html
        wget https://wordpress.org/latest.tar.gz
        tar -xf latest.tar.gz
        rm latest.tar.gz
        chown -R www-data:www-data wordpress

        # Configure WordPress
        cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
        sed -i \"s/database_name_here/wordpress/g\" /var/www/html/wordpress/wp-config.php
        sed -i \"s/username_here/admin/g\" /var/www/html/wordpress/wp-config.php
        sed -i \"s/password_here/password1234/g\" /var/www/html/wordpress/wp-config.php
        sed -i \"s/localhost/${azurerm_mysql_server.example.fqdn}/g\" /var/www/html/wordpress/wp-config.php

        systemctl restart apache2
      "
    }
SETTINGS
}
