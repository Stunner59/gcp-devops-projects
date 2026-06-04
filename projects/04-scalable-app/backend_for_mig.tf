resource "google_compute_backend_service" "web_backend" {
  name                  = "web-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  port_name             = "http"
  timeout_sec           = 10

  health_checks = [
    google_compute_health_check.http.id
  ]

  backend {
    group = google_compute_region_instance_group_manager.web_mig.instance_group
  }
}

resource "google_compute_url_map" "web_url_map" {
  name            = "web-url-map"
  default_service = google_compute_backend_service.web_backend.id
}


resource "google_compute_target_http_proxy" "web_proxy" {
  name    = "web-proxy"
  url_map = google_compute_url_map.web_url_map.id
}
