# ============================================================
# Helm Release - Prometheus (kube-prometheus-stack)
# ============================================================
# Deployed as a separate Helm release because the combined
# umbrella chart exceeds Kubernetes Secret size limits (1MB)
# and API request limits (3MB).
# ============================================================

resource "helm_release" "prometheus" {
  count            = var.enable_prometheus ? 1 : 0
  name             = "weaura-prometheus"
  namespace        = var.monitoring_namespace
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "82.4.3"
  create_namespace = false
  wait             = true
  wait_for_jobs    = true
  timeout          = 900
  atomic           = true
  cleanup_on_fail  = true
  skip_crds        = true # CRDs already exist on cluster

  values = [
    templatefile(
      "${path.module}/templates/prometheus-values-aws.yaml.tpl",
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
