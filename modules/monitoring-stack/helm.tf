# ============================================================
# Helm Release - WeAura Monitoring Stack
# ============================================================
# Deploys umbrella chart from WeAura ECR OCI registry.
# Chart pulls automatically via IAM cross-account authentication.
# ============================================================

# --------------------------------
# ECR Authentication Data
# --------------------------------

data "aws_ecr_authorization_token" "token" {
  registry_id = var.ecr_account_id
}

# --------------------------------
# Helm Release
# --------------------------------

resource "helm_release" "monitoring" {
  name       = "weaura-monitoring"
  namespace  = var.namespace
  repository = local.chart_oci_url
  chart      = "weaura-monitoring"
  version    = var.chart_version


  # ECR authentication (automatic via AWS provider)
  repository_username = "AWS"
  repository_password = data.aws_ecr_authorization_token.token.password

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
