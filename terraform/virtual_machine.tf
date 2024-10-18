resource "azurerm_resource_group" "semi-colon" {
  name     = "semi-colon-vm"
  location = "UK South"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "myVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.semi-colon.location
  resource_group_name = azurerm_resource_group.semi-colon.name
  depends_on          = [azurerm_resource_group.semi-colon]
}

resource "azurerm_subnet" "subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.semi-colon.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on           = [azurerm_virtual_network.vnet]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.semi-colon.location
  resource_group_name = azurerm_resource_group.semi-colon.name
  allocation_method   = "Static"  # Must be Static for Standard SKU
  sku                 = "Standard"  # Set SKU to Standard
  depends_on          = [azurerm_resource_group.semi-colon]
}
resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  location            = azurerm_resource_group.semi-colon.location
  resource_group_name = azurerm_resource_group.semi-colon.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"   # Corrected here
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "AllowAppPort3000"
    priority                   = 1010  
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on          = [azurerm_resource_group.semi-colon]
}


resource "azurerm_network_interface" "nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.semi-colon.location
  resource_group_name = azurerm_resource_group.semi-colon.name

  ip_configuration {
    name                          = "myIPConfig"
    subnet_id                    = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"

    # Create a public IP
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
  depends_on             = [azurerm_resource_group.semi-colon]
}
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on          = [azurerm_network_interface.nic]

}

resource "azurerm_virtual_machine" "vm" {
  name                  = "myVM"
  location              = azurerm_resource_group.semi-colon.location
  resource_group_name   = azurerm_resource_group.semi-colon.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"

  # Specify the source image reference
  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  # Define the operating system disk
  storage_os_disk {
    name              = "myVMosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"

    # Specify the source image
    managed_disk_type = "Standard_LRS"  # Specify disk type if needed
  }
  delete_os_disk_on_termination = true
  os_profile {
    computer_name  = "semi-colon"
    admin_username = "azureuser"
    admin_password = "bahnasy"  # Change this to a secure password
    
  }
 

  os_profile_linux_config {
    disable_password_authentication = true
     ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = file("/var/lib/jenkins/.ssh/id_rsa.pub")  
    }
  }
  depends_on          = [azurerm_network_interface.nic]
}