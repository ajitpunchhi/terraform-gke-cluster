# environments/dev/outputs.tf

output "vpc_name" {
  description = "The name of the VPC"
  value       = module.gke_infrastructure.vpc_name
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = module.gke_infrastructure.subnet_name
}

output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = module.gke_infrastructure.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE cluster"
  value       = module.gke_infrastructure.cluster_endpoint
}

output "load_balancer_ip" {
  description = "The IP address of the load balancer"
  value       = module.gke_infrastructure.load_balancer_ip
}