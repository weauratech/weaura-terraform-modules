# ============================================================
# Helm Release - Pyroscope
# ============================================================
# Deployed as a separate Helm release for continuous profiling.
# Disabled by default — enable via enable_pyroscope.
# ============================================================

resource "helm_release" "pyroscope" {
  count            = var.enable_pyroscope ? 1 : 0
  name             = "weaura-pyroscope"
  namespace        = var.monitoring_namespace
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "pyroscope"
  version          = var.pyroscope_chart_version
  create_namespace = false
  wait             = true
  wait_for_jobs    = true
  timeout          = 900
  atomic           = true
  cleanup_on_fail  = true

  values = [
    templatefile(
      "${path.module}/templates/pyroscope-values-aws.yaml.tpl",
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
