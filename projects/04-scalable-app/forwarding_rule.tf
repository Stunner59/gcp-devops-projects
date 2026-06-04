resource "google_compute_global_address" "web_ip" {
  name = "web-lb-ip"
}

resource "google_compute_global_forwarding_rule" "web_forwarding_rule" {
  name                  = "web-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"

  ip_address = google_compute_global_address.web_ip.address

  port_range = "80"

  target = google_compute_target_http_proxy.web_proxy.id
}
