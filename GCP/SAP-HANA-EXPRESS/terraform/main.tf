provider "google" {
    project         = "bc-stage-2021"
    region          = "europe-west1"
    zone            = "europe-west1-b"
    credentials     = "C:/bc-stage-2021-62766e939e40.json"
}

# resource "google_compute_address" "static" {
#   name = "terraform-static-ip"
# }

data "google_compute_image" "rhel_image" {
  family  = "rhel-7-4-sap"
  project = "rhel-sap-cloud"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-test-werner"
  machine_type = "e2-medium"

  tags = ["terraform"]

  boot_disk {
    initialize_params {
      size  = "256"
      image = data.google_compute_image.rhel_image.self_link
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "test-terraform"
    access_config {
        network_tier = "STANDARD"
    }
  }

  metadata_startup_script = "sudo yum install git -y && sudo yum install ansible -y && sudo yum install -y ftp && sudo yum install -y expect && git clone https://github.com/DenysSlyvka/Flexso_SAP_Autodeploy.git"
}

# resource "null_resource" "provision_vm" {
#     ///Make SSH connection
#     connection {
#             type        = "ssh"
#             user        = "azureuser"
#             private_key = tls_private_key.example_ssh.private_key_pem
#             host        = network_interface.0.access_config.0.nat_ip
#             agent       = "false"
#     }

#     # provisioner "file" {
#     #     source      = "install.rsp"
#     #     destination = "/tmp/install.rsp"
#     # }

#     # provisioner "file" {
#     #     source      = "install.rsp.xml"
#     #     destination = "/tmp/install.rsp.xml"
#     # }


#     provisioner "remote-exec" {
#         inline = [
#             "echo Move centos1.repo to /etc/yum.repos.d/",
#             "sudo mv /var/tmp/centos1.repo /etc/yum.repos.d/",
#             "echo chowning root repo",
#             "sudo chown root:root /etc/yum.repos.d/centos1.repo",
#             "echo updating repos",
#             "sudo yum update -y --disablerepo='*' --enablerepo='*microsoft*'",
#             "echo installing EPEL Repo",
#             "sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y",
#             "echo disable bad repo",
#             "sudo yum-config-manager --disable rhel-ha-for-rhel-7-server-eus-rhui-rpms",
#             "echo yuminstall nmap -y",
#             "sudo yum install nmap -y", 
#             "echo install pexpect", 
#             "sudo cd /etc/yum.repos.d/", 
#             "echo downloading pexpect 3.3 repo into yum", 
#             "sudo wget https://download.opensuse.org/repositories/home:uibmz:opsi:opsi40/RHEL_7/home:uibmz:opsi:opsi40.repo", 
#             "echo installing python with yum", 
#             "sudo yum install -y python-pexpect", 
#             "echo install compat-sap-c++-7-7.2.1-2.el7_4",  
#             "sudo rpm -ivh ftp://ftp.pbone.net/mirror/ftp.scientificlinux.org/linux/scientific/7.8/x86_64/os/Packages/compat-sap-c++-7-7.2.1-2.el7_4.x86_64.rpm", 
#             "echo install litool-ltdl",  
#             "sudo yum install -y libtool-ltdl", 
#             "echo install libatomic", 
#             "sudo yum install -y libatomic", 
#             "echo install ansbile",
#             "sudo yum install -y ansible",
#             "echo yum install git", 
#             "sudo yum -y install git", 
#             "echo install FTP",
#             "sudo yum install -y ftp",
#             "git clone https://github.com/DenysSlyvka/Flexso_SAP_Autodeploy.git", 
#             //"sudo ansible-playbook ~/Flexso_SAP_Autodeploy/Azure/SAP-HANA-EXPRESS/ansible/site.yml" 
#         ]  
#         on_failure = continue
#     }
# }