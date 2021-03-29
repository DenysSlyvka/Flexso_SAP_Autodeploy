provider "google" {
    project         = "bc-stage-2021"
    region          = "europe-west1"
    zone            = "europe-west1-b"
    credentials     = "C:/bc-stage-2021-62766e939e40.json"
}

data "google_compute_image" "rhel_image" {
  family  = "rhel-8-2-sap-ha"
  project = "rhel-sap-cloud"
}

resource "google_compute_instance" "vm_instance" {
  name         = "myvm"
  machine_type = "n1-highmem-32"

  tags = ["terraform"]

  boot_disk {
    initialize_params {
      size  = "1000"
      image = data.google_compute_image.rhel_image.self_link
      type = "pd-ssd"
    }
  }

  network_interface {
    network = "test-terraform"
    access_config {
        network_tier = "STANDARD"
    }
  }
 # Password for rsync command? -> metadata_startup_script = "sudo yum install ftp -y && sudo yum install rsync -y && rsync -alPvz flexsostageadmin@51.103.26.163:/home/flexsostageadmin/ftp/HANA-PLATFORM/51054623 /home/werner_deschryver/Downloads/"
 # metadata_startup_script = "sudo yum install git -y && sudo yum install -y ftp && sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && sudo yum install ansible -y && sudo yum install -y ftp://ftp.pbone.net/mirror/ftp.redhat.com/pub/redhat/rhel/rhel-8-beta/appstream/aarch64/Packages/python3-pexpect-4.3.1-3.el8.noarch.rpm && sudo yum install rsync -y && git clone https://github.com/DenysSlyvka/Flexso_SAP_Autodeploy.git"
}