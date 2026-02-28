# ============================================================
# Helm Release - Monitoring (Umbrella Chart)
# ============================================================
# Deploys the weaura-monitoring umbrella chart that consolidates
# all 6 monitoring components into a single release.
# Chart is pulled from Harbor OCI registry.
# ============================================================

resource "helm_release" "monitoring" {
  name             = "weaura-monitoring"
  namespace        = var.monitoring_namespace
  repository       = var.monitoring_chart_repository
  chart            = "weaura-monitoring"
  version          = var.monitoring_chart_version
  create_namespace = false
  wait             = true
  wait_for_jobs    = true
  timeout          = 900
  atomic           = true
  cleanup_on_fail  = true
  skip_crds        = true # CRDs installed separately (too large for release secret)

  repository_username = var.harbor_username
  repository_password = var.harbor_password

  values = [
    templatefile(
      "${path.module}/templates/monitoring-values-aws.yaml.tpl",
      local.monitoring_template_vars
    )
  ]

  # SSO credentials injected as sensitive values
  dynamic "set_sensitive" {
    for_each = var.grafana_sso_enabled && var.grafana_sso_provider == "github" ? [1] : []
    content {
      name  = "grafana.env.GF_AUTH_GITHUB_CLIENT_ID"
      value = var.grafana_sso_client_id
    }
  }

  dynamic "set_sensitive" {
    for_each = var.grafana_sso_enabled && var.grafana_sso_provider == "github" ? [1] : []
    content {
      name  = "grafana.env.GF_AUTH_GITHUB_CLIENT_SECRET"
      value = var.grafana_sso_client_secret
    }
  }

  dynamic "set_sensitive" {
    for_each = var.grafana_sso_enabled && var.grafana_sso_provider == "google" ? [1] : []
    content {
      name  = "grafana.env.GF_AUTH_GOOGLE_CLIENT_ID"
      value = var.grafana_sso_client_id
    }
  }

  dynamic "set_sensitive" {
    for_each = var.grafana_sso_enabled && var.grafana_sso_provider == "google" ? [1] : []
    content {
      name  = "grafana.env.GF_AUTH_GOOGLE_CLIENT_SECRET"
      value = var.grafana_sso_client_secret
    }
  }

  depends_on = [
    # Kubernetes resources
    kubernetes_namespace.this,
    kubernetes_limit_range.this,
    kubernetes_service_account.workload_identity,

    # AWS dependencies
    aws_iam_role.irsa,
    aws_iam_role_policy_attachment.irsa_s3,
    aws_s3_bucket.this,
  ]
}
