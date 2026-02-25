terraform {
  backend "gcs" {
    bucket = "gcp-devops-tf-state-001"
    prefix = "dev"
  }
}
