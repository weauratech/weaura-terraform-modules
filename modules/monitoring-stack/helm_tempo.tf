# ============================================================
# Helm Release - Tempo
# ============================================================
# Deployed as a separate Helm release for distributed tracing.
# Disabled by default — enable via enable_tempo.
# ============================================================

resource "helm_release" "tempo" {
  count            = var.enable_tempo ? 1 : 0
  name             = "weaura-tempo"
  namespace        = var.monitoring_namespace
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "tempo"
  version          = var.tempo_chart_version
  create_namespace = false
  wait             = true
  wait_for_jobs    = true
  timeout          = 900
  atomic           = true
  cleanup_on_fail  = true

  values = [
    templatefile(
      "${path.module}/templates/tempo-values-aws.yaml.tpl",
      local.monitoring_template_vars
    )
  ]

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
