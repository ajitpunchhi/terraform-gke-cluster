# environments/dev/variables.tf

variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "The region for GCP resources"
  type        = string
  default     = "us-central1"
}

variable "zones" {
  description = "The zones for GCP resources"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "regional" {
  description = "Whether to create a regional cluster"
  type        = bool
  default     = true
}

# VPC Variables
variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "pod_cidr" {
  description = "CIDR range for pods"
  type        = string
  default     = "10.16.0.0/14"
}

variable "service_cidr" {
  description = "CIDR range for services"
  type        = string
  default     = "10.20.0.0/20"
}

# GKE Variables
variable "enable_autopilot" {
  description = "Whether to create an Autopilot cluster"
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "The service account email for GKE nodes"
  type        = string
}

variable "private_cluster" {
  description = "Whether to create a private cluster"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Whether to enable private endpoint"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "The CIDR block for the master's private IP range"
  type        = string
  default     = "172.16.0.0/28"
}

variable "release_channel" {
  description = "The release channel for GKE"
  type        = string
  default     = "REGULAR"
}

variable "node_pools" {
  description = "List of node pool configurations"
  type = list(object({
    name               = string
    node_count         = number
    preemptible        = bool
    machine_type       = string
    disk_size_gb       = number
    disk_type          = string
    enable_autoscaling = bool
    min_node_count     = number
    max_node_count     = number
    max_surge          = number
    max_unavailable    = number
    labels             = map(string)
    tags               = list(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = []
}
# Storage Variables
variable "storage_namespace" {
  description = "Kubernetes namespace for storage resources"
  type        = string
  default     = "default"
}

variable "create_shared_pvc" {
  description = "Whether to create a shared PVC"
  type        = bool
  default     = true
}

variable "shared_pvc_size" {
  description = "Size of the shared PVC"
  type        = string
  default     = "50Gi"
}

# Load Balancer Variables
variable "backend_port_name" {
  description = "The name of the backend port"
  type        = string
  default     = "http"
}

variable "health_check_port" {
  description = "The port for health checks"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "The path for health checks"
  type        = string
  default     = "/healthz"
}

variable "enable_cdn" {
  description = "Whether to enable Cloud CDN"
  type        = bool
  default     = false
}

variable "enable_ssl" {
  description = "Whether to enable SSL with a managed certificate"
  type        = bool
  default     = false
}

variable "ssl_domains" {
  description = "List of domains for the SSL certificate"
  type        = list(string)
  default     = []
}

variable "host_rules" {
  description = "List of host rules"
  type = list(object({
    hosts        = list(string)
    path_matcher = string
  }))
  default = []
}

variable "path_matchers" {
  description = "List of path matchers"
  type = list(object({
    name = string
    path_rules = list(object({
      paths = list(string)
    }))
  }))
  default = []
}