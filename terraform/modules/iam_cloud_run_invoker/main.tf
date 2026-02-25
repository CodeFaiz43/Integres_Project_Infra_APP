resource "google_cloud_run_v2_service_iam_member" "cloud_run_invoker" {
  name     = var.cloud_run_service_name
  location = var.location
  project  = var.project_id

  role   = "roles/run.invoker"
  member = "serviceAccount:${var.invoker_service_account_email}"
}
