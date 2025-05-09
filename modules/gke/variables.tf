# modules/gke/variables.tf

variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "The region for the GKE cluster"
  type        = string
}

variable "zones" {
  description = "The zones for the GKE cluster"
  type        = list(string)
  default     = []
}

variable "regional" {
  description = "Whether this is a regional cluster (or zonal)"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

variable "pod_range_name" {
  description = "The name of the pod IP range"
  type        = string
}

variable "service_range_name" {
  description = "The name of the service IP range"
  type        = string
}

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
  description = "Whether to enable private endpoint (access to master through private IP)"
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

variable "logging_service" {
  description = "The logging service to use"
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
  description = "The monitoring service to use"
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

variable "enable_binary_authorization" {
  description = "Whether to enable binary authorization"
  type        = bool
  default     = false
}

variable "maintenance_start_time" {
  description = "The start time for maintenance window in RFC3339 format"
  type        = string
  default     = "2023-01-01T00:00:00Z"
}

variable "maintenance_end_time" {
  description = "The end time for maintenance window in RFC3339 format"
  type        = string
  default     = "2023-01-01T04:00:00Z"
}

variable "maintenance_recurrence" {
  description = "The recurrence for maintenance window in RFC5545 format"
  type        = string
  default     = "FREQ=WEEKLY;BYDAY=SA,SU"
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
