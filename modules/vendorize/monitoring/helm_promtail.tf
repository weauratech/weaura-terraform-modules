resource "helm_release" "promtail" {
  count = var.enable_log_collector ? 1 : 0

  name       = "weaura-promtail"
  namespace  = var.monitoring_namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = var.promtail_chart_version

  timeout = 600
  wait    = false

  values = [
    templatefile("${path.module}/templates/promtail-values-aws.yaml.tpl", {
      loki_push_url     = "${local.datasource_urls.loki}/loki/api/v1/push"
      target_namespaces = var.log_collector_target_namespaces
      namespace         = var.monitoring_namespace
    })
  ]

  depends_on = [
    helm_release.monitoring
  ]
}
