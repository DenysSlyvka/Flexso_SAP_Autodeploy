provider "google" {
    project         = "bc-stage-2021"
    region          = "europe-west1"
    zone            = "europe-west1-b"
    credentials     = "C:/bc-stage-2021-62766e939e40.json"
}

data "google_compute_image" "rhel_image" {
  family  = "rhel-7-4-sap"
  project = "rhel-sap-cloud"
}

resource "google_compute_instance" "vm_instance" {
  name         = "myvm"
  machine_type = "e2-standard-8"

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

  metadata_startup_script = "sudo yum install git -y && sudo yum install ansible -y && sudo yum install -y ftp && yum install wget -y && wget https://download.opensuse.org/repositories/home:uibmz:opsi:opsi40/RHEL_7/home:uibmz:opsi:opsi40.repo -P /etc/yum.repos.d/ && yum install python-pexpect -y && git clone https://github.com/DenysSlyvka/Flexso_SAP_Autodeploy.git && ansible-playbook Flexso_SAP_Autodeploy/GCP/SAP-HANA-EXPRESS/ansible/site.yml"
}