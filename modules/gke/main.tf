# modules/gke/main.tf

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.regional ? var.region : var.zones[0]
  project  = var.project_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.vpc_name
  subnetwork = var.subnet_name

  # IP allocation policy for pods and services
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pod_range_name
    services_secondary_range_name = var.service_range_name
  }

  # Enable Autopilot if specified
  enable_autopilot = var.enable_autopilot

  # Standard cluster specific settings
  dynamic "node_config" {
    for_each = var.enable_autopilot ? [] : [1]
    content {
      # Use minimal service account with least privileges
      service_account = var.service_account_email
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }

  # Networking settings
  networking_mode = "VPC_NATIVE"

  # Private cluster settings if enabled
  dynamic "private_cluster_config" {
    for_each = var.private_cluster ? [1] : []
    content {
      enable_private_nodes    = true
      enable_private_endpoint = var.enable_private_endpoint
      master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    }
  }

  # Control plane settings
  release_channel {
    channel = var.release_channel
  }

  # Workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Logging and monitoring
  logging_service    = var.logging_service
  monitoring_service = var.monitoring_service

  # Binary authorization
  dynamic "binary_authorization" {
    for_each = var.enable_binary_authorization ? [1] : []
    content {
      evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
    }
  }

  # Maintenance window
  maintenance_policy {
    recurring_window {
      start_time = var.maintenance_start_time
      end_time   = var.maintenance_end_time
      recurrence = var.maintenance_recurrence
    }
  }
}

# Create node pools only for standard clusters (not for Autopilot)
resource "google_container_node_pool" "primary_nodes" {
  count = var.enable_autopilot ? 0 : length(var.node_pools)

  name       = var.node_pools[count.index].name
  location   = var.regional ? var.region : var.zones[0]
  cluster    = google_container_cluster.primary.name
  node_count = var.node_pools[count.index].node_count
  project    = var.project_id

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = var.node_pools[count.index].preemptible
    machine_type = var.node_pools[count.index].machine_type
    disk_size_gb = var.node_pools[count.index].disk_size_gb
    disk_type    = var.node_pools[count.index].disk_type

    service_account = var.service_account_email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = var.node_pools[count.index].labels
    tags   = var.node_pools[count.index].tags

    # Kubernetes taints
    dynamic "taint" {
      for_each = var.node_pools[count.index].taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    # Shielded instance options
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  # Upgrade settings
  upgrade_settings {
    max_surge       = var.node_pools[count.index].max_surge
    max_unavailable = var.node_pools[count.index].max_unavailable
  }

  # Auto-scaling configuration
  dynamic "autoscaling" {
    for_each = var.node_pools[count.index].enable_autoscaling ? [1] : []
    content {
      min_node_count = var.node_pools[count.index].min_node_count
      max_node_count = var.node_pools[count.index].max_node_count
    }
  }
}