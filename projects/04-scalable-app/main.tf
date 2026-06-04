resource "google_compute_instance_template" "web_template" {
  name_prefix  = "web-template-"
 # name = instance
  machine_type = "e2-micro"
 region = var.region
  tags = ["web", "allow-ssh"]

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.public_subnet
  }

lifecycle {
    create_before_destroy = true
  }
  metadata_startup_script = file("${path.module}/startup.sh")
}
