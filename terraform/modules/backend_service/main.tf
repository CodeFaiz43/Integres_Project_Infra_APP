resource "google_compute_backend_service" "backend_service" {
  name                  = var.name
  protocol              = "HTTP"
  timeout_sec           = 30
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = var.neg_id
  }
}
