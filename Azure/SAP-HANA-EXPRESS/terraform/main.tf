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
  name = "Flexso-Stage-TestEnv-Denys"
  location = "francecentral"
}

///The following section creates a virtual network named myVnet in the 10.0.0.0/16 address space:
resource "azurerm_virtual_network" "myterraformnetworktest" {
    name                = "myVnet-testDisks"
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
    allocation_method            = "Static"

    tags = {
        environment = "Terraform SAP Automation Demo"
    }
}

resource "local_file" "PublicIP" {
    content     = azurerm_public_ip.myterraformpublicip.ip_address
    filename = "C:/ssh_keys/publicIP.txt"
}

//Create Network Security Group
///Network Security Groups control the flow of network traffic in and out of your VM. 
///The following section creates a network security group named myNetworkSecurityGroup and 
//defines a rule to allow SSH traffic on TCP port 22:
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "francecentral"
    resource_group_name = azurerm_resource_group.saptestautodeploygroup.name

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
    resource_group_name         = azurerm_resource_group.saptestautodeploygroup.name
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

//output "tls_private_key" { value = tls_private_key.example_ssh.private_key_pem }

resource "local_file" "sshkey" {
    content     = tls_private_key.example_ssh.private_key_pem
    filename = "C:/ssh_keys/sshkey.pem"
}

///Collect public IP once VM has booted
# data "azurerm_public_ip" "publicip" {
#   name                = azurerm_public_ip.myterraformpublicip.name
#   resource_group_name = azurerm_resource_group.saptestautodeploygroup.name
# }


resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "francecentral"
    resource_group_name   = azurerm_resource_group.saptestautodeploygroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = "Standard_D8s_v3"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
        disk_size_gb = 256
    }

    source_image_reference {
        publisher = "RedHat"
        offer     = "RHEL-SAP-HANA"
        sku       = "7.2"
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


resource "azurerm_managed_disk" "example" {
  name                 = "myvm-disk1"
  location             = azurerm_resource_group.saptestautodeploygroup.location
  resource_group_name  = azurerm_resource_group.saptestautodeploygroup.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 256
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.example.id
  virtual_machine_id = azurerm_linux_virtual_machine.myterraformvm.id
  lun                = "10"
  caching            = "ReadWrite"
}


resource "null_resource" "provision_vm" {
    ///Make SSH connection
    connection {
            type        = "ssh"
            user        = "azureuser"
            private_key = tls_private_key.example_ssh.private_key_pem
            host        = azurerm_public_ip.myterraformpublicip.ip_address
            agent       = "false"
    }

    # provisioner "local-exec" {
    #     command = "ssh -i ${tls_private_key.example_ssh.private_key_pem} azureuser@${azurerm_public_ip.myterraformpublicip.ip_address}"
    #     depends_on = [
    #         azurerm_public_ip.myterraformpublicip
    #     ]
    #  }


    provisioner "file" {
        source      = "centos1.repo"
        destination = "/var/tmp/centos1.repo"
    }

    provisioner "file" {
        source      = "install.rsp"
        destination = "/tmp/install.rsp"
    }

    provisioner "file" {
        source      = "install.rsp.xml"
        destination = "/tmp/install.rsp.xml"
    }


    provisioner "remote-exec" {
        inline = [
            "echo Move centos1.repo to /etc/yum.repos.d/",
            "sudo mv /var/tmp/centos1.repo /etc/yum.repos.d/",
            "echo chowning root repo",
            "sudo chown root:root /etc/yum.repos.d/centos1.repo",
            "echo updating repos",
            "sudo yum update -y --disablerepo='*' --enablerepo='*microsoft*'",
            "echo installing EPEL Repo",
            "sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y",
            "echo disable bad repo",
            "sudo yum-config-manager --disable rhel-ha-for-rhel-7-server-eus-rhui-rpms",
            "echo yuminstall nmap -y",
            "sudo yum install nmap -y", 
            "echo install pexpect", 
            "sudo cd /etc/yum.repos.d/", 
            "echo downloading pexpect 3.3 repo into yum", 
            "sudo wget https://download.opensuse.org/repositories/home:uibmz:opsi:opsi40/RHEL_7/home:uibmz:opsi:opsi40.repo", 
            "echo installing python with yum", 
            "sudo yum install -y python-pexpect", 
            "echo install compat-sap-c++-7-7.2.1-2.el7_4",  
            "sudo rpm -ivh ftp://ftp.pbone.net/mirror/ftp.scientificlinux.org/linux/scientific/7.8/x86_64/os/Packages/compat-sap-c++-7-7.2.1-2.el7_4.x86_64.rpm", 
            "echo install litool-ltdl",  
            "sudo yum install -y libtool-ltdl", 
            "echo install libatomic", 
            "sudo yum install -y libatomic", 
            "echo install ansbile",
            "sudo yum install -y ansible",
            "echo yum install git", 
            "sudo yum -y install git", 
            "git clone https://github.com/DenysSlyvka/Flexso_SAP_Autodeploy.git", 
            "sudo ansible-playbook ~/Flexso_SAP_Autodeploy/Azure/SAP-HANA-EXPRESS/ansible/site.yml" 
        ]  
        on_failure = continue
    }
}
