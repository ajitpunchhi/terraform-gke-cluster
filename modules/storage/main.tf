# modules/storage/main.tf

# Create a Storage Class for SSD persistent disks
resource "kubernetes_storage_class" "ssd" {
  metadata {
    name = "ssd-storage"
  }
  storage_provisioner = "kubernetes.io/gce-pd"
  reclaim_policy      = "Retain"
  parameters = {
    type = "pd-ssd"
  }
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true
}

# Create a Storage Class for standard persistent disks
resource "kubernetes_storage_class" "standard" {
  metadata {
    name = "standard-storage"
  }
  storage_provisioner = "kubernetes.io/gce-pd"
  reclaim_policy      = "Retain"
  parameters = {
    type = "pd-standard"
  }
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true
}

# Optionally create PVCs for common storage needs
resource "kubernetes_persistent_volume_claim" "shared_data" {
  count = var.create_shared_pvc ? 1 : 0
  
  metadata {
    name      = "shared-data-pvc"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.standard.metadata[0].name
    resources {
      requests = {
        storage = var.shared_pvc_size
      }
    }
  }
}