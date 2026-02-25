variable "env_name" {
  type    = string
  default = null
}

variable "env_value" {
  type    = string
  default = null
}

variable "name" {
  type        = string
  description = "The name of the Cloud Run service to create. Example: dev-ml-service."
}

variable "location" {
  type        = string
  description = "The GCP region where the Cloud Run service will be deployed. Example: us-central1."
}

variable "image" {
  type        = string
  description = "The full container image path stored in Artifact Registry. Example: us-central1-docker.pkg.dev/project-id/repo/image:v1."
}

variable "service_account_email" {
  type        = string
  description = "The email of the service account that the Cloud Run service will run as."
}

variable "ingress" {
  type        = string
  description = "Defines how the Cloud Run service receives traffic. Options: INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY, INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER."
}


