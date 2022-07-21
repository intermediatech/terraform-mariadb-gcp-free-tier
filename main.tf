variable "credentials_json" {
  type = string
  description = "Default filename for credentials file"
  default = "credentials.json"
}

variable "keyfile_pub" {
  type = string
  default = "id_rsa.pub"
}

variable "project_name" {
  type = string
  description = "Project name / id"
  default = "gcp_free_tier"
}

variable "company" {
  type = string
  default = "octoyoung"
}

variable "instance_name" {
  type = string
  default = "free_tier_instance"
}

variable "tags" {
  type = list(string)
  default = [ "gcp_free" ]
}

variable "server_use" {
  type = string
  default = "database"
}

variable "ports" {
  type = list(string)
  default = [ "3306" ]
}

variable "ssh_user" {
  type = string
  default = "vishnu"  
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.21.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_json)
  project     = var.project_name
  region      = "us-central1"
  zone        = "us-central1-c"
}


resource "google_compute_instance" "instance_with_ip" {
  name         = var.instance_name
  machine_type = "e2-micro"
  zone         = "us-central1-c"

  tags = var.tags

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size = 30
      type = "pd-standard"
    }
  }


  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    server_use = var.server_use
  }

  metadata_startup_script = file("${path.module}/init.sh")

}


resource "google_compute_firewall" "default" {
  name    = "${var.company}-fw-allow-access"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = var.ports
  }

   target_tags = var.tags
   source_ranges = [ "0.0.0.0/32" ]

}

resource "google_compute_address" "static" {
  name = "freetier-ip"
}

resource "google_os_login_ssh_public_key" "cache" {
  user =  data.google_client_openid_userinfo.me.email
  key = file(var.keyfile_pub)
}

resource "google_compute_project_metadata" "my_ssh_key" {
  project = var.project_name
  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.keyfile_pub)}"
  }
}

data "google_client_openid_userinfo" "me" {
}