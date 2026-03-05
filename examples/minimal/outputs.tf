output "grafana_url" {
  description = "Internal Grafana service URL"
  value       = module.monitoring.grafana_url
}

output "loki_url" {
  description = "Internal Loki service URL"
  value       = module.monitoring.loki_url
}

output "prometheus_url" {
  description = "Internal Prometheus service URL"
  value       = module.monitoring.prometheus_url
}

output "namespace" {
  description = "Kubernetes namespace where monitoring is deployed"
  value       = module.monitoring.namespace
}

output "helm_release_status" {
  description = "Status of the Helm release"
  value       = module.monitoring.helm_release_status
}
