# ============================================================
# Helm Release - Mimir (mimir-distributed)
# ============================================================
# Deployed as a separate Helm release for long-term metrics
# storage. Disabled by default — enable via enable_mimir.
# ============================================================

resource "helm_release" "mimir" {
  count            = var.enable_mimir ? 1 : 0
  name             = "weaura-mimir"
  namespace        = var.monitoring_namespace
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "mimir-distributed"
  version          = var.mimir_chart_version
  create_namespace = false
  wait             = true
  wait_for_jobs    = true
  timeout          = 900
  atomic           = true
  cleanup_on_fail  = true

  values = [
    templatefile(
      "${path.module}/templates/mimir-values-aws.yaml.tpl",
      local.monitoring_template_vars
    )
  ]

  depends_on = [
    # Kubernetes resources
    kubernetes_namespace.this,
    kubernetes_limit_range.this,
    kubernetes_service_account.workload_identity,
    kubernetes_storage_class.this,

    # AWS dependencies
    aws_iam_role.irsa,
    aws_iam_role_policy_attachment.irsa_s3,
    aws_s3_bucket.this,
  ]
}
