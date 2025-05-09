# modules/storage/variables.tf

variable "namespace" {
  description = "Kubernetes namespace where resources will be created"
  type        = string
  default     = "default"
}

variable "create_shared_pvc" {
  description = "Whether to create a shared PVC"
  type        = bool
  default     = false
}

variable "shared_pvc_size" {
  description = "Size of the shared PVC (e.g. '100Gi')"
  type        = string
  default     = "10Gi"
}
