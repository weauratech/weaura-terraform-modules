# ============================================================
# Kubernetes Resources - Harbor Container Registry
# ============================================================
# Namespace, ResourceQuota, LimitRange, NetworkPolicy,
# and ServiceAccount for Harbor.
# ============================================================

# -----------------------------
# Namespace
# -----------------------------
resource "kubernetes_namespace" "harbor" {
  metadata {
    name = local.namespace

    labels = merge(local.common_labels, {
      "app.kubernetes.io/name"      = "harbor"
      "app.kubernetes.io/component" = "container-registry"
      "terraform.io/managed"        = "true"
    })

    annotations = {
      "description" = "Harbor Container Registry for ${var.project} ${var.environment}"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["kubectl.kubernetes.io/last-applied-configuration"]
    ]
  }
}

# -----------------------------
# Resource Quota
# -----------------------------
resource "kubernetes_resource_quota" "harbor" {
  count = var.enable_resource_quotas ? 1 : 0

  metadata {
    name      = "harbor-quota"
    namespace = kubernetes_namespace.harbor.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    hard = {
      "requests.cpu"           = var.resource_quota.requests_cpu
      "requests.memory"        = var.resource_quota.requests_memory
      "limits.cpu"             = var.resource_quota.limits_cpu
      "limits.memory"          = var.resource_quota.limits_memory
      "persistentvolumeclaims" = var.resource_quota.pvcs
      "services"               = var.resource_quota.services
      "secrets"                = var.resource_quota.secrets
      "configmaps"             = var.resource_quota.configmaps
    }
  }
}

# -----------------------------
# Limit Range
# -----------------------------
resource "kubernetes_limit_range" "harbor" {
  count = var.enable_limit_ranges ? 1 : 0

  metadata {
    name      = "harbor-limits"
    namespace = kubernetes_namespace.harbor.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.limit_range.default_cpu
        memory = var.limit_range.default_memory
      }
      default_request = {
        cpu    = var.limit_range.default_request_cpu
        memory = var.limit_range.default_request_memory
      }
      min = {
        cpu    = var.limit_range.min_cpu
        memory = var.limit_range.min_memory
      }
      max = {
        cpu    = var.limit_range.max_cpu
        memory = var.limit_range.max_memory
      }
    }
  }
}

# -----------------------------
# Network Policy
# -----------------------------
resource "kubernetes_network_policy" "harbor" {
  count = var.enable_network_policies ? 1 : 0

  metadata {
    name      = "allow-harbor-traffic"
    namespace = kubernetes_namespace.harbor.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]

    # Allow traffic from the same namespace
    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = local.namespace
          }
        }
      }
    }

    # Allow traffic from ingress controller namespace
    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "kube-system"
          }
        }
      }
    }

    # Allow traffic from all namespaces (for docker pulls)
    ingress {
      from {
        namespace_selector {}
      }
      ports {
        port     = "5000"
        protocol = "TCP"
      }
    }
  }
}

# -----------------------------
# Service Account for IRSA
# -----------------------------
# The Helm chart creates its own service accounts, but we create one
# with IRSA annotation for the registry component to access S3
resource "kubernetes_service_account" "harbor_registry" {
  count = local.is_aws ? 1 : 0

  metadata {
    name      = "harbor-registry"
    namespace = kubernetes_namespace.harbor.metadata[0].name
    labels    = local.common_labels
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.harbor[0].arn
    }
  }

  # Don't create default token
  automount_service_account_token = true
}
