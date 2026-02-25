output "lb_ip_address" {
  description = "Public IP address of Load Balancer"
  value       = google_compute_global_address.lb_ip.address
}
