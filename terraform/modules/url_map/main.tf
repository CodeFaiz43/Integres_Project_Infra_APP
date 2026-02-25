resource "google_compute_url_map" "url_map" {
  name            = var.name
  default_service = var.backend_service_id
}
