# modules/storage/outputs.tf

output "ssd_storage_class_name" {
  description = "Name of the SSD storage class"
  value       = kubernetes_storage_class.ssd.metadata[0].name
}

output "standard_storage_class_name" {
  description = "Name of the standard storage class"
  value       = kubernetes_storage_class.standard.metadata[0].name
}

output "shared_pvc_name" {
  description = "Name of the shared PVC if created"
  value       = var.create_shared_pvc ? kubernetes_persistent_volume_claim.shared_data[0].metadata[0].name : null
}