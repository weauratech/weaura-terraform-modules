# ============================================================
# Helm Release - WeAura Monitoring Stack
# ============================================================
# Deploys umbrella chart from WeAura Harbor OCI registry.
# Chart pulls automatically via IAM cross-account authentication.
# ============================================================

# --------------------------------
# Harbor Authentication Data
# --------------------------------


# --------------------------------
# Helm Release
# --------------------------------

resource "helm_release" "monitoring" {
  name       = "weaura-monitoring"
  namespace  = var.namespace
  repository = local.chart_oci_url
  chart      = "weaura-monitoring"
  version    = var.chart_version


  # Harbor authentication (via provided credentials)
  repository_username = var.harbor_username
  repository_password = var.harbor_password

  # Wait for all components to be ready
  wait             = true
  wait_for_jobs    = true
  timeout          = 600
  cleanup_on_fail  = true
  create_namespace = false # Already created separately

  # Pass constructed values
  values = [
    yamlencode(local.helm_values)
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
    kubernetes_service_account.loki,
    kubernetes_service_account.mimir,
    kubernetes_service_account.tempo,
    kubernetes_service_account.pyroscope,
    aws_s3_bucket.loki,
    aws_s3_bucket.mimir,
    aws_s3_bucket.tempo,
    aws_s3_bucket.pyroscope
  ]
}
