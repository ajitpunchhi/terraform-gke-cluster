# modules/load_balancer/main.tf

# Create a global HTTP(S) load balancer
resource "google_compute_global_address" "default" {
  name         = var.lb_name
  project      = var.project_id
  description  = "Global IP for ${var.lb_name} load balancer"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

# Create a backend service
resource "google_compute_backend_service" "default" {
  name                  = "${var.lb_name}-backend"
  project               = var.project_id
  protocol              = "HTTP"
  port_name             = var.backend_port_name
  timeout_sec           = 30
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.default.id]

  dynamic "backend" {
    for_each = var.neg_name != null ? [1] : []
    content {
      group = "projects/${var.project_id}/zones/${var.zone}/networkEndpointGroups/${var.neg_name}"
    }
  }

  dynamic "backend" {
    for_each = var.instance_group_url != null ? [1] : []
    content {
      group = var.instance_group_url
    }
  }

  # Enable Cloud CDN if specified
  dynamic "cdn_policy" {
    for_each = var.enable_cdn ? [1] : []
    content {
      cache_mode                   = "CACHE_ALL_STATIC"
      client_ttl                   = 3600
      default_ttl                  = 3600
      max_ttl                      = 86400
      negative_caching             = true
      cache_key_policy {
        include_host         = true
        include_protocol     = true
        include_query_string = true
      }
    }
  }
}

# Create a URL map
resource "google_compute_url_map" "default" {
  name            = "${var.lb_name}-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.default.id

  # Custom URL paths if provided
  dynamic "host_rule" {
    for_each = var.host_rules
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }

  dynamic "path_matcher" {
    for_each = var.path_matchers
    content {
      name            = path_matcher.value.name
      default_service = google_compute_backend_service.default.id

      dynamic "path_rule" {
        for_each = path_matcher.value.path_rules
        content {
          paths   = path_rule.value.paths
          service = google_compute_backend_service.default.id
        }
      }
    }
  }
}

# Create a health check
resource "google_compute_health_check" "default" {
  name                = "${var.lb_name}-health-check"
  project             = var.project_id
  timeout_sec         = 5
  check_interval_sec  = 10

  http_health_check {
    port               = var.health_check_port
    port_specification = "USE_FIXED_PORT"
    request_path       = var.health_check_path
  }
}

# Create an HTTP target proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "${var.lb_name}-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.default.id
}

# Create an HTTPS target proxy if SSL is enabled
resource "google_compute_target_https_proxy" "default" {
  count   = var.enable_ssl ? 1 : 0
  name    = "${var.lb_name}-https-proxy"
  project = var.project_id
  url_map = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default[0].id]
}

# Create a managed SSL certificate if SSL is enabled
resource "google_compute_managed_ssl_certificate" "default" {
  count   = var.enable_ssl ? 1 : 0
  name    = "${var.lb_name}-cert"
  project = var.project_id

  managed {
    domains = var.ssl_domains
  }
}

# Create forwarding rules
resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.lb_name}-http-rule"
  project               = var.project_id
  ip_address            = google_compute_global_address.default.address
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_global_forwarding_rule" "https" {
  count                 = var.enable_ssl ? 1 : 0
  name                  = "${var.lb_name}-https-rule"
  project               = var.project_id
  ip_address            = google_compute_global_address.default.address
  port_range            = "443"
  target                = google_compute_target_https_proxy.default[0].id
  load_balancing_scheme = "EXTERNAL"
}
