# modules/load_balancer/variables.tf

variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "zone" {
  description = "The zone where the load balancer resources are located"
  type        = string
}

variable "lb_name" {
  description = "The name of the load balancer"
  type        = string
}

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
  default     = "/"
}

variable "neg_name" {
  description = "The name of the Network Endpoint Group to associate with this LB"
  type        = string
  default     = null
}

variable "instance_group_url" {
  description = "The URL of the instance group to associate with this LB"
  type        = string
  default     = null
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
