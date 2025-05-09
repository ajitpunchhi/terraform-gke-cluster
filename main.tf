# main.tf

module "vpc" {
  source = "./modules/vpc"

  project_id   = var.project_id
  region       = var.region
  vpc_name     = var.vpc_name
  subnet_name  = var.subnet_name
  subnet_cidr  = var.subnet_cidr
  pod_cidr     = var.pod_cidr
  service_cidr = var.service_cidr
}

module "gke" {
  source = "./modules/gke"
  depends_on = [module.vpc]

  project_id           = var.project_id
  region               = var.region
  zones                = var.zones
  regional             = var.regional
  cluster_name         = var.cluster_name
  vpc_name             = module.vpc.vpc_name
  subnet_name          = module.vpc.subnet_name
  pod_range_name       = module.vpc.pod_range_name
  service_range_name   = module.vpc.service_range_name
  enable_autopilot     = var.enable_autopilot
  service_account_email = var.service_account_email
  private_cluster      = var.private_cluster
  enable_private_endpoint = var.enable_private_endpoint
  master_ipv4_cidr_block = var.master_ipv4_cidr_block
  release_channel      = var.release_channel
  node_pools           = var.node_pools
}

# Only create Kubernetes resources if not using Autopilot
module "storage" {
  source = "./modules/storage"
  count  = var.enable_autopilot ? 0 : 1
  depends_on = [module.gke]

  namespace        = var.storage_namespace
  create_shared_pvc = var.create_shared_pvc
  shared_pvc_size  = var.shared_pvc_size
}

module "load_balancer" {
  source = "./modules/load_balancer"
  depends_on = [module.gke]

  project_id        = var.project_id
  zone              = var.zones[0]
  lb_name           = var.lb_name
  backend_port_name = var.backend_port_name
  health_check_port = var.health_check_port
  health_check_path = var.health_check_path
  neg_name          = var.neg_name
  instance_group_url = var.instance_group_url
  enable_cdn        = var.enable_cdn
  enable_ssl        = var.enable_ssl
  ssl_domains       = var.ssl_domains
  host_rules        = var.host_rules
  path_matchers     = var.path_matchers
}