resource "google_compute_global_address" "lb_ip" {
  name = "${var.name}-ip"
}

resource "google_compute_global_forwarding_rule" "http_rule" {
  name       = var.name
  target     = var.http_proxy_id
  port_range = "80"
  ip_address = google_compute_global_address.lb_ip.address
}
