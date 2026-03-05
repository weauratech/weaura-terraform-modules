# --------------------------------
# Monitoring Stack Outputs
# --------------------------------

output "namespace" {
  description = "Kubernetes namespace where monitoring is deployed"
  value       = module.monitoring.namespace
}

output "grafana_url" {
  description = "Internal Grafana service URL"
  value       = module.monitoring.grafana_url
}

output "grafana_ingress_host" {
  description = "Grafana ingress hostname (if enabled)"
  value       = module.monitoring.grafana_ingress_host
}

output "loki_url" {
  description = "Internal Loki service URL"
  value       = module.monitoring.loki_url
}

output "mimir_url" {
  description = "Internal Mimir service URL"
  value       = module.monitoring.mimir_url
}

output "tempo_url" {
  description = "Internal Tempo service URL"
  value       = module.monitoring.tempo_url
}

output "prometheus_url" {
  description = "Internal Prometheus service URL"
  value       = module.monitoring.prometheus_url
}

output "pyroscope_url" {
  description = "Internal Pyroscope service URL"
  value       = module.monitoring.pyroscope_url
}

output "s3_buckets" {
  description = "S3 bucket names for monitoring components"
  value       = module.monitoring.s3_buckets
}

output "iam_role_arn" {
  description = "IAM role ARN for monitoring service accounts"
  value       = module.monitoring.iam_role_arn
}

output "pod_identity_role_arn" {
  description = "Pod Identity IAM role ARN"
  value       = module.monitoring.pod_identity_role_arn
}

output "pod_identity_associations" {
  description = "Map of Pod Identity associations by component"
  value       = module.monitoring.pod_identity_associations
}

output "helm_release_status" {
  description = "Status of the Helm release"
  value       = module.monitoring.helm_release_status
}

output "enabled_components" {
  description = "List of enabled monitoring components"
  value       = module.monitoring.enabled_components
}

output "enterprise_features" {
  description = "Map of enterprise feature enablement status"
  value       = module.monitoring.enterprise_features
}
