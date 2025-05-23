# modules/vpc/outputs.tf

output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "pod_range_name" {
  description = "The name of the pod IP range"
  value       = "pod-range"
}

output "service_range_name" {
  description = "The name of the service IP range"
  value       = "service-range"
}