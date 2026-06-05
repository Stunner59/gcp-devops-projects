packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "asia-south1"
}

variable "zone" {
  type    = string
  default = "asia-south1-a"
}

source "googlecompute" "jenkins" {
  project_id          = var.project_id
  source_image_family = "debian-12"
  zone                = var.zone
  machine_type        = "e2-medium"
  disk_size           = 30
  image_name          = "jenkins-ha-{{timestamp}}"
  image_family        = "jenkins-ha"
  image_description   = "Jenkins HA image built with Packer and Ansible"
  ssh_username        = "packer"
  network             = "devops-vpc"
  subnetwork          = "devops-vpc-public-subnet"
  tags                = ["allow-ssh"]
  use_iap             = true

  metadata = {
    enable-oslogin = "TRUE"
  }
}

build {
  name    = "jenkins-ha"
  sources = ["source.googlecompute.jenkins"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 2; done"
    ]
  }

  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yml"
    extra_arguments = [
      "--become",
      "-e", "ansible_python_interpreter=/usr/bin/python3"
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
