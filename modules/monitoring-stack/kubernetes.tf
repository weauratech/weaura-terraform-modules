# ============================================================
# Kubernetes Resources - Observability Stack
# ============================================================
# Single unified namespace, ResourceQuota, LimitRange, and
# NetworkPolicy for the observability stack.
# Service accounts per storage component for IRSA.
# ============================================================

# -----------------------------
# StorageClass (EBS gp3 with WaitForFirstConsumer)
# -----------------------------
# Creates a dedicated StorageClass for the observability stack.
# Uses WaitForFirstConsumer to prevent PV zone-affinity conflicts:
# the PV is only provisioned AFTER the pod is scheduled to a node,
# guaranteeing the EBS volume is created in the same AZ as the node.
# This permanently prevents the "volume node affinity conflict" issue
# that occurs when PVs are created in AZs with no available nodes.
# -----------------------------
resource "kubernetes_storage_class" "this" {
  count = var.create_storage_class ? 1 : 0

  metadata {
    name = var.storage_class

    labels = merge(local.common_labels, {
      "app.kubernetes.io/name"      = "ebs-storage"
      "app.kubernetes.io/component" = "storage"
      "terraform.io/managed"        = "true"
    })

    annotations = {
      "description" = "GP3 EBS StorageClass with WaitForFirstConsumer for zone-safe PV provisioning"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = var.storage_class_reclaim_policy
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = var.storage_class_ebs_type
    fsType    = "ext4"
    encrypted = tostring(var.storage_class_encrypted)
  }
}

# -----------------------------
# Single Namespace
# -----------------------------
resource "kubernetes_namespace" "this" {
  metadata {
    name = var.monitoring_namespace

    labels = merge(local.common_labels, {
      "app.kubernetes.io/name"      = "observability-stack"
      "app.kubernetes.io/component" = "monitoring"
      "terraform.io/managed"        = "true"
    })

    annotations = {
      "description" = "Unified observability monitoring namespace"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["kubectl.kubernetes.io/last-applied-configuration"]
    ]
  }
}

# -----------------------------
# Resource Quota (single)
# -----------------------------
# NOTE: Using lifecycle ignore_changes to prevent race conditions with Helm.
# Helm charts may also try to update these quotas, causing "the object has been modified" errors.
resource "kubernetes_resource_quota" "this" {
  count = var.enable_resource_quotas ? 1 : 0

  metadata {
    name      = "monitoring-quota"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    hard = {
      "requests.cpu"           = "100"
      "requests.memory"        = "200Gi"
      "limits.cpu"             = "200"
      "limits.memory"          = "400Gi"
      "persistentvolumeclaims" = "80"
      "services"               = "120"
      "secrets"                = "150"
      "configmaps"             = "200"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].resource_version,
      metadata[0].annotations["kubectl.kubernetes.io/last-applied-configuration"],
    ]
  }
}

# -----------------------------
# Limit Range (single)
# -----------------------------
resource "kubernetes_limit_range" "this" {
  count = var.enable_limit_ranges ? 1 : 0

  metadata {
    name      = "monitoring-limits"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "500m"
        memory = "512Mi"
      }
      default_request = {
        cpu    = "100m"
        memory = "128Mi"
      }
      min = {
        cpu    = "10m"
        memory = "16Mi"
      }
      max = {
        cpu    = "8"
        memory = "16Gi"
      }
    }
  }
}

# -----------------------------
# Network Policy (single)
# -----------------------------
resource "kubernetes_network_policy" "this" {
  count = var.enable_network_policies ? 1 : 0

  metadata {
    name      = "allow-observability-stack"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]

    ingress {
      from {
        namespace_selector {}
      }
    }
  }
}

# -----------------------------
# Service Accounts for Workload Identity
# -----------------------------
# Creates service accounts with cloud-specific annotations for workload identity
# IMPORTANT: Labels are set to be Helm-compatible to avoid conflicts when Helm
# charts try to manage the same ServiceAccount. Helm expects:
# - app.kubernetes.io/managed-by: Helm
# - meta.helm.sh/release-name: <release-name>
# - meta.helm.sh/release-namespace: <namespace>
resource "kubernetes_service_account" "workload_identity" {
  for_each = local.enabled_storage_components

  metadata {
    name      = each.key
    namespace = kubernetes_namespace.this.metadata[0].name
    # Use Helm-compatible labels to avoid conflicts with Helm releases
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/part-of"    = "observability-stack"
      "environment"                  = var.environment
      "cloud-provider"               = var.cloud_provider
    }
    # Include Helm release annotations + cloud-specific workload identity annotations
    annotations = merge(
      # Helm release metadata (required for Helm to adopt this resource)
      {
        "meta.helm.sh/release-name"      = each.key
        "meta.helm.sh/release-namespace" = kubernetes_namespace.this.metadata[0].name
      },
      # Cloud-specific workload identity annotations
      {
        "eks.amazonaws.com/role-arn" = aws_iam_role.irsa[each.key].arn
      }
    )
  }

  # Ignore changes to labels/annotations that Helm might modify
  lifecycle {
    ignore_changes = [
      metadata[0].labels["app.kubernetes.io/instance"],
      metadata[0].labels["app.kubernetes.io/name"],
      metadata[0].labels["app.kubernetes.io/version"],
      metadata[0].labels["helm.sh/chart"],
      metadata[0].annotations["kubectl.kubernetes.io/last-applied-configuration"],
    ]
  }
}
