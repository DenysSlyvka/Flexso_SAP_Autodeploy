terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}


provider "azurerm" {
    subscription_id = "03770d81-ed60-40f1-8f52-bcc2ad3841f4"
    client_id       = "d68ba4cd-a861-407b-9769-5dc5c10d2170"
    client_secret   = "BpmSrLSijYMdLDeo.-vTjPq_cUlU6aUBEg"
    tenant_id       = "58f8e72b-7946-4e10-bdbb-cc6eb93e1c89"
    features {}
}

//Create virtual network
///The following section creates a resource group named Flexso-Stage-TestEnv in the francecentral location:
resource "azurerm_resource_group" "saptestautodeploygroup" {
  name = "Flexso-Stage-TestEnv"
  location = "francecentral"
}

///The following section creates a virtual network named myVnet in the 10.0.0.0/16 address space:
resource "azurerm_virtual_network" "myterraformnetworktest" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "francecentral"
    resource_group_name = azurerm_resource_group.saptestautodeploygroup.name

    tags = {
        environment = "Terraform SAP Automation Demo"
    }
}

///The following section creates a subnet named mySubnet in the myVnet virtual network:
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.saptestautodeploygroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetworktest.name
    address_prefixes       = ["10.0.2.0/24"]
}

//Create public IP address
///To access resources across the Internet, create and assign a public IP address to your VM. 
///The following section creates a public IP address named myPublicIP:
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "francecentral"
    resource_group_name          = azurerm_resource_group.saptestautodeploygroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform SAP Automation Demo"
    }
}

//Create Network Security Group
///Network Security Groups control the flow of network traffic in and out of your VM. 
///The following section creates a network security group named myNetworkSecurityGroup and 
//defines a rule to allow SSH traffic on TCP port 22:
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "francecentral"
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform SAP Automation Demo"
    }
}

//Create virtual network interface card
///A virtual network interface card (NIC) connects your VM to a given virtual network, 
///public IP address, and network security group. 
///The following section in a Terraform template creates a virtual NIC named myNIC connected 
///to the virtual networking resources you've created:
resource "azurerm_network_interface" "myterraformnic" {
    name                        = "myNIC"
    location                    = "francecentral"
    resource_group_name         = azurerm_resource_group.saptestautodeploygroup.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = {
        environment = "Terraform SAP Automation Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

//Create storage account for diagnostics
///To store boot diagnostics for a VM, you need a storage account. 
///These boot diagnostics can help you troubleshoot problems and monitor the status of your VM. 
///The storage account you create is only to store the boot diagnostics data. 
///As each storage account must have a unique name, the following section generates some random text:
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.saptestautodeploygroup.name
    }

    byte_length = 8
}
///Now you can create a storage account. The following section creates a storage account, 
///with the name based on the random text generated in the preceding step:
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myterraformsubnet.name
    location                    = "francecentral"
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = "Terraform SAP Automation Demo"
    }
}

//Create virtual machine
///The final step is to create a VM and use all the resources created. 
///The following section creates a VM named myVM and attaches the virtual NIC named myNIC.
///The latest Ubuntu 18.04-LTS image is used,
///and a user named azureuser is created with password authentication disabled.
///SSH key data is provided in the ssh_keys section. Provide a public SSH key in the key_data field.

resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tls_private_key" { value = tls_private_key.example_ssh.private_key_pem }

resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "francecentral"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = "Standard_D8s_v3"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.example_ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo"
    }
}