# modules/load_balancer/outputs.tf

output "load_balancer_ip" {
  description = "The IP address of the load balancer"
  value       = google_compute_global_address.default.address
}

output "lb_name" {
  description = "The name of the load balancer"
  value       = var.lb_name
}

output "backend_service_name" {
  description = "The name of the backend service"
  value       = google_compute_backend_service.default.name
}

output "http_proxy_name" {
  description = "The name of the HTTP proxy"
  value       = google_compute_target_http_proxy.default.name
}

output "https_proxy_name" {
  description = "The name of the HTTPS proxy"
  value       = var.enable_ssl ? google_compute_target_https_proxy.default[0].name : null
}