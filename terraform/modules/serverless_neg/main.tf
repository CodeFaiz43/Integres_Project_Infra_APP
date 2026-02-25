resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = var.name
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = var.cloud_run_service_name
  }
}
