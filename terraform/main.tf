# Enable required APIs
resource "google_project_service" "required_services" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])

  service            = each.key
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "integres_docker_repo" {
  location      = var.region
  repository_id = "${var.environment}-docker-repo"
  description   = "Docker repository for Cloud Run services"
  format        = "DOCKER"
}



module "backend_service_account" {
  source       = "./modules/service_account"
  account_id   = "${var.environment}-backend-sa"
  display_name = "Backend Cloud Run Service Account"
}

module "frontend_service_account" {
  source       = "./modules/service_account"
  account_id   = "${var.environment}-frontend-sa"
  display_name = "Frontend Cloud Run Service Account"
}

module "backend_cloud_run" {
  source                = "./modules/cloud_run"
  name                  = "${var.environment}-backend-service"
  location              = var.region
  image                 = "us-central1-docker.pkg.dev/${var.project_id}/${var.environment}-docker-repo/backend-service:v5"
  service_account_email = module.backend_service_account.email
  #ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  #
  ingress = "INGRESS_TRAFFIC_ALL"
}

module "frontend_cloud_run" {
  source = "./modules/cloud_run"

  name                  = "${var.environment}-frontend-service"
  location              = var.region
  image                 = "us-central1-docker.pkg.dev/${var.project_id}/${var.environment}-docker-repo/frontend-service:v5"
  service_account_email = module.frontend_service_account.email
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  env_name              = "BACKEND_URL"
  env_value             = module.backend_cloud_run.service_url
  depends_on            = [module.backend_cloud_run]
}


#cloud run invoker role for frontend to invoke backend service
module "frontend_invokes_backend" {
  source                        = "./modules/iam_cloud_run_invoker"
  project_id                    = var.project_id
  location                      = var.region
  cloud_run_service_name        = module.backend_cloud_run.service_name
  invoker_service_account_email = module.frontend_service_account.email
  depends_on                    = [module.backend_cloud_run]
}

#serverless NEG for frontend service
module "frontend_neg" {
  source                 = "./modules/serverless_neg"
  name                   = "${var.environment}-frontend-serverless-neg"
  region                 = var.region
  cloud_run_service_name = module.frontend_cloud_run.service_name
}

# Backend service for frontend NEG
module "frontend_backend_service" {
  source = "./modules/backend_service"
  name   = "${var.environment}-frontend-backend"
  neg_id = module.frontend_neg.neg_id
}

# URL map for frontend service
module "frontend_url_map" {
  source             = "./modules/url_map"
  name               = "${var.environment}-frontend-url-map"
  backend_service_id = module.frontend_backend_service.backend_service_id
}

# HTTP proxy for frontend service
module "frontend_http_proxy" {
  source = "./modules/http_proxy"

  name       = "${var.environment}-frontend-http-proxy"
  url_map_id = module.frontend_url_map.url_map_id
}

# Global forwarding rule for frontend service
module "frontend_http_forwarding" {
  source        = "./modules/http_forwarding"
  name          = "${var.environment}-frontend-http-rule"
  http_proxy_id = module.frontend_http_proxy.http_proxy_id
}


# Allow public access to frontend (for testing)
resource "google_cloud_run_v2_service_iam_member" "frontend_public" {
  name       = module.frontend_cloud_run.service_name
  location   = var.region
  project    = var.project_id
  role       = "roles/run.invoker"
  member     = "allUsers"
  depends_on = [module.frontend_cloud_run]
}
