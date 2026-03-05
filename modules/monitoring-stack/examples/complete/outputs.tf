# ============================================================
# Output Values - Complete Example
# ============================================================

# --------------------------------
# Grafana Access
# --------------------------------

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = module.monitoring_stack.grafana_url
}

output "grafana_admin_user" {
  description = "Grafana admin username"
  value       = module.monitoring_stack.grafana_admin_user
}

output "grafana_namespace" {
  description = "Kubernetes namespace where Grafana is deployed"
  value       = module.monitoring_stack.grafana_namespace
}

# --------------------------------
# Component Endpoints
# --------------------------------

output "prometheus_url" {
  description = "Prometheus internal service URL"
  value       = module.monitoring_stack.prometheus_url
}

output "loki_url" {
  description = "Loki internal service URL"
  value       = module.monitoring_stack.loki_url
}

output "mimir_url" {
  description = "Mimir internal service URL"
  value       = module.monitoring_stack.mimir_url
}

output "tempo_url" {
  description = "Tempo internal service URL"
  value       = module.monitoring_stack.tempo_url
}

output "pyroscope_url" {
  description = "Pyroscope internal service URL"
  value       = module.monitoring_stack.pyroscope_url
}

output "datasource_urls" {
  description = "Map of all datasource URLs for Grafana configuration"
  value       = module.monitoring_stack.datasource_urls
}

# --------------------------------
# AWS Resources
# --------------------------------

output "aws_s3_bucket_names" {
  description = "Names of S3 buckets created"
  value       = module.monitoring_stack.aws_s3_bucket_names
}

output "aws_s3_bucket_arns" {
  description = "ARNs of S3 buckets created"
  value       = module.monitoring_stack.aws_s3_bucket_arns
}

output "aws_iam_role_arns" {
  description = "ARNs of IAM roles for IRSA"
  value       = module.monitoring_stack.aws_iam_role_arns
}

# --------------------------------
# Helm Releases
# --------------------------------

output "helm_releases" {
  description = "Status of all Helm releases"
  value       = module.monitoring_stack.helm_releases
}

# --------------------------------
# Deployment Summary
# --------------------------------

output "module_summary" {
  description = "Summary of module deployment"
  value       = module.monitoring_stack.module_summary
}

output "namespaces" {
  description = "Monitoring namespaces"
  value       = module.monitoring_stack.namespaces
}

output "storage_configuration" {
  description = "Cloud-agnostic storage configuration summary"
  value       = module.monitoring_stack.storage_configuration
}
