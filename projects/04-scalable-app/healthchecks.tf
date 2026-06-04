resource "google_compute_health_check" "http" {
  name = "web-health-check"

  http_health_check {
    port = 80
  }
}
