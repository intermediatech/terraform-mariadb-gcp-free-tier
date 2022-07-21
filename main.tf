variable "credentials_json" {
  type = string
  description = "Default filename for credentials file"
  default = "credentials.json"
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
  project     = "maindb-350707"
  region      = "us-central1"
  zone        = "us-central1-c"
}


resource "google_compute_instance" "instance_with_ip" {
  name         = "maindb"
  machine_type = "e2-micro"
  zone         = "us-central1-c"

  tags = ["database"]

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
    server_use = "database"
  }

    metadata_startup_script = file("${path.module}/init.sh")

}


resource "google_compute_firewall" "default" {
  name    = "database"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["5509","3306"]
  }

}

resource "google_compute_address" "static" {
  name = "maindb"
}

resource "google_os_login_ssh_public_key" "cache" {
  user =  data.google_client_openid_userinfo.me.email
  key = file("id_rsa.pub")
}

data "google_client_openid_userinfo" "me" {
}