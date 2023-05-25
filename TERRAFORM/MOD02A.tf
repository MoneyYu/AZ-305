## LAB-02A-VM
resource "azurerm_virtual_network" "lab02a" {
  name                = "${local.lab02a_name}-vnet-${local.random_str}"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.az305.location
  resource_group_name = azurerm_resource_group.az305.name

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_subnet" "lab02a" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.az305.name
  virtual_network_name = azurerm_virtual_network.lab02a.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "lab02abastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.az305.name
  virtual_network_name = azurerm_virtual_network.lab02a.name
  address_prefixes     = ["10.10.2.0/24"]
}

resource "azurerm_network_security_group" "lab02a" {
  name                = "${local.lab02a_name}-vnet-subnet-nsg-${local.random_str}"
  location            = azurerm_resource_group.az305.location
  resource_group_name = azurerm_resource_group.az305.name

  security_rule {
    name                       = "HTTPS-IN"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "Internet"
    destination_port_range     = "443"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "GATEWAY-HTTPS-IN"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "GatewayManager"
    destination_port_range     = "443"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "LB-HTTPS-IN"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_port_range     = "443"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "BASTION-IN"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_port_ranges    = ["5701", "8080"]
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "SSH-RDP-OUT"
    priority                   = 210
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_ranges    = ["22", "3389"]
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AZURE-OUT"
    priority                   = 220
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "AzureCloud"
    destination_port_range     = "443"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "BASTION-OUT"
    priority                   = 230
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_port_ranges    = [5701, 8080]
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "HTTP-OUT"
    priority                   = 240
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "80"
    destination_address_prefix = "Internet"
  }

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_subnet_network_security_group_association" "lab02a" {
  subnet_id                 = azurerm_subnet.lab02a.id
  network_security_group_id = azurerm_network_security_group.lab02a.id
}

resource "azurerm_subnet_network_security_group_association" "lab02abastion" {
  subnet_id                 = azurerm_subnet.lab02abastion.id
  network_security_group_id = azurerm_network_security_group.lab02a.id
}

resource "azurerm_public_ip" "lab02a" {
  name                = "${local.lab02a_name}-pip-${local.random_str}"
  location            = azurerm_resource_group.az305.location
  resource_group_name = azurerm_resource_group.az305.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  domain_name_label   = "${local.lab02a_name}-vm-${local.random_str}"

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_public_ip" "lab02abastion" {
  name                = "${local.lab02a_name}-bastion-pip-${local.random_str}"
  location            = azurerm_resource_group.az305.location
  resource_group_name = azurerm_resource_group.az305.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${local.lab02a_name}-bastion-${local.random_str}"

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_bastion_host" "lab02a" {
  name                   = "${local.lab02a_name}-bastion-${local.random_str}"
  location               = azurerm_resource_group.az305.location
  resource_group_name    = azurerm_resource_group.az305.name
  sku                    = "Standard"
  file_copy_enabled      = true
  ip_connect_enabled     = true
  shareable_link_enabled = true
  tunneling_enabled      = true

  ip_configuration {
    name                 = "${local.lab02a_name}-bastion-ipconfig-${local.random_str}"
    subnet_id            = azurerm_subnet.lab02abastion.id
    public_ip_address_id = azurerm_public_ip.lab02abastion.id
  }

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_network_interface" "lab02a" {
  name                = "${local.lab02a_name}-nic-${local.random_str}"
  location            = azurerm_resource_group.az305.location
  resource_group_name = azurerm_resource_group.az305.name

  ip_configuration {
    name                          = "${local.lab02a_name}-nic-ipconfig-${local.random_str}"
    subnet_id                     = azurerm_subnet.lab02a.id
    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = azurerm_public_ip.lab02a.id
  }

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_windows_virtual_machine" "lab02a" {
  name                  = "${local.lab02a_name}-vm-${local.random_str}"
  location              = azurerm_resource_group.az305.location
  resource_group_name   = azurerm_resource_group.az305.name
  network_interface_ids = [azurerm_network_interface.lab02a.id]
  size                  = local.vm_size

  os_disk {
    name                 = "${local.lab02a_name}-osdisk-${local.random_str}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  computer_name  = "${local.lab02a_name}-vm-${local.random_str}"
  admin_username = local.user_name
  admin_password = local.user_passowrd

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_virtual_machine_extension" "lab02aad" {
  name                       = "${local.lab02a_name}-aad-${local.random_str}"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  virtual_machine_id         = azurerm_windows_virtual_machine.lab02a.id

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_virtual_machine_extension" "lab02script" {
  name                       = "${local.lab02a_name}-script-${local.random_str}"
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true
  virtual_machine_id         = azurerm_windows_virtual_machine.lab02a.id

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools && powershell.exe remove-item 'C:\\inetpub\\wwwroot\\iisstart.htm' && powershell.exe Add-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value $('Hello World from ' + $env:computername)"
    }
  SETTINGS

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_windows_virtual_machine_scale_set" "lab02a" {
  name                = "${local.lab02a_name}vms"
  resource_group_name = azurerm_resource_group.az305.name
  location            = azurerm_resource_group.az305.location
  sku                 = local.vm_size
  instances           = 2
  admin_username      = local.user_name
  admin_password      = local.user_passowrd

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "${local.lab02a_name}-vmss-nic-${local.random_str}"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.lab02a.id
    }
  }

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "lab02avmssscript" {
  name                         = "${local.lab02a_name}-vmss-script-${local.random_str}"
  virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.lab02a.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools && powershell.exe remove-item 'C:\\inetpub\\wwwroot\\iisstart.htm' && powershell.exe Add-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value $('Hello World from ' + $env:computername)"
    }
  SETTINGS
}
