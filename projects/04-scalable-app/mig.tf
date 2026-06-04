resource "google_compute_region_instance_group_manager" "web_mig" {
  name   = "web-mig"
  region = var.region

  version {
    instance_template = google_compute_instance_template.web_template.id
  }

  base_instance_name = "java-web"

  target_size = 2

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http.id
    initial_delay_sec = 60
  }
}
