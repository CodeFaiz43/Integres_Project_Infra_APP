resource "google_compute_target_http_proxy" "http_proxy" {
  name    = var.name
  url_map = var.url_map_id
}
