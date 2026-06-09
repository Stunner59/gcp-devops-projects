terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "project-b0c0dfc1-64aa-430f-a96-tfstate"
    prefix = "jenkins-ha/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Service Account for Jenkins VMs
resource "google_service_account" "jenkins_sa" {
  account_id   = "jenkins-ha-sa"
  display_name = "Jenkins HA Service Account"
}

# Allow Jenkins SA to access GCS bucket
resource "google_storage_bucket_iam_member" "jenkins_gcs" {
  bucket = var.gcs_bucket
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.jenkins_sa.email}"
}

# Instance Template
resource "google_compute_instance_template" "jenkins" {
  name_prefix  = "jenkins-ha-"
  machine_type = "e2-medium"
  region       = var.region
  tags         = ["jenkins", "allow-ssh"]

  disk {
    source_image = "projects/${var.project_id}/global/images/family/jenkins-ha"
    auto_delete  = true
    boot         = true
    disk_size_gb = 30
  }

  network_interface {
    network    = "devops-vpc"
    subnetwork = "devops-vpc-public-subnet"
    access_config {}
  }

  service_account {
    email  = google_service_account.jenkins_sa.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = <<-SCRIPT
      #!/bin/bash
      mkdir -p /var/lib/jenkins
      gcsfuse --implicit-dirs ${var.gcs_bucket} /var/lib/jenkins
      chown -R jenkins:jenkins /var/lib/jenkins
      systemctl restart jenkins
    SCRIPT
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Health Check
resource "google_compute_health_check" "jenkins" {
  name               = "jenkins-health-check"
  check_interval_sec = 30
  timeout_sec        = 10
  healthy_threshold  = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = 8080
    request_path = "/login"
  }
}

# Managed Instance Group
resource "google_compute_region_instance_group_manager" "jenkins" {
  name               = "jenkins-ha-mig"
  base_instance_name = "jenkins"
  region             = var.region

  version {
    instance_template = google_compute_instance_template.jenkins.id
  }

  target_size = 1

  named_port {
    name = "jenkins"
    port = 8080
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.jenkins.id
    initial_delay_sec = 300
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 1
    max_unavailable_fixed = 0
  }
}

# Firewall rule for Jenkins
resource "google_compute_firewall" "jenkins" {
  name    = "allow-jenkins"
  network = "devops-vpc"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins"]
}

# Load Balancer backend
resource "google_compute_backend_service" "jenkins" {
  name                  = "jenkins-backend"
  protocol              = "HTTP"
  port_name             = "jenkins"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.jenkins.id]

  backend {
    group           = google_compute_region_instance_group_manager.jenkins.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# URL Map
resource "google_compute_url_map" "jenkins" {
  name            = "jenkins-url-map"
  default_service = google_compute_backend_service.jenkins.id
}

# HTTP Proxy
resource "google_compute_target_http_proxy" "jenkins" {
  name    = "jenkins-http-proxy"
  url_map = google_compute_url_map.jenkins.id
}

# Load Balancer frontend
resource "google_compute_global_forwarding_rule" "jenkins" {
  name                  = "jenkins-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.jenkins.id
}
