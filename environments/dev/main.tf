module "gke_infrastructure" {
  source = "../.." # Root module

  # Project Configuration
  project_id = var.project_id
  region     = var.region
  zones      = var.zones
  regional   = var.regional

  # VPC Configuration
  vpc_name    = "${var.environment}-vpc"
  subnet_name = "${var.environment}-subnet"
  subnet_cidr = var.subnet_cidr
  pod_cidr    = var.pod_cidr
  service_cidr = var.service_cidr

  # GKE Configuration
  cluster_name = "${var.environment}-cluster"
  enable_autopilot = var.enable_autopilot
  service_account_email = var.service_account_email
  private_cluster = var.private_cluster
  enable_private_endpoint = var.enable_private_endpoint
  master_ipv4_cidr_block = var.master_ipv4_cidr_block
  release_channel = var.release_channel
  node_pools = var.node_pools

  # Storage Configuration
  storage_namespace = var.storage_namespace
  create_shared_pvc = var.create_shared_pvc
  shared_pvc_size   = var.shared_pvc_size

  # Load Balancer Configuration
  lb_name = "${var.environment}-lb"
  backend_port_name = var.backend_port_name
  health_check_port = var.health_check_port
  health_check_path = var.health_check_path
  enable_cdn = var.enable_cdn
  enable_ssl = var.enable_ssl
  ssl_domains = var.ssl_domains
  host_rules = var.host_rules
  path_matchers = var.path_matchers
}