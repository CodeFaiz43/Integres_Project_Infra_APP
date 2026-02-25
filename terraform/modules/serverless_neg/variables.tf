variable "name" {
  description = "Name of the Serverless NEG"
  type        = string
}

variable "region" {
  description = "Region where the NEG will be created"
  type        = string
}

variable "cloud_run_service_name" {
  description = "Cloud Run service name to attach"
  type        = string
}
