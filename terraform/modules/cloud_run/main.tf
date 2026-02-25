resource "google_cloud_run_v2_service" "service" {
  name     = var.name
  location = var.location

  template {
    service_account = var.service_account_email

    containers {
      image = var.image

      ports {
        container_port = 8080
      }

      dynamic "env" {
        for_each = var.env_name == null ? [] : [1]
        content {
          name  = var.env_name
          value = var.env_value
        }
      }
    }
  }

  ingress = var.ingress
}
