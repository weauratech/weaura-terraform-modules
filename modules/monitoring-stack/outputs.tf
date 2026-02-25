# ============================================================
# Output Values
# ============================================================

# --------------------------------
# Namespace Information
# --------------------------------

output "namespace" {
  description = "Kubernetes namespace where monitoring stack is deployed"
  value       = var.namespace
}

# --------------------------------
# Grafana Outputs
# --------------------------------

output "grafana_url" {
  description = "Internal Grafana service URL (cluster-local)"
  value       = var.grafana.enabled ? "http://grafana.${var.namespace}.svc.cluster.local" : null
}

output "grafana_admin_username" {
  description = "Grafana admin username"
  value       = var.grafana.enabled ? "admin" : null
}

output "grafana_ingress_host" {
  description = "Grafana ingress hostname (if ingress is enabled)"
  value       = var.grafana.enabled && var.grafana.ingress_enabled ? var.grafana.ingress_host : null
}

# --------------------------------
# Component Endpoints
# --------------------------------

output "loki_url" {
  description = "Internal Loki service URL (cluster-local)"
  value       = var.loki.enabled ? "http://loki.${var.namespace}.svc.cluster.local:3100" : null
}

output "mimir_url" {
  description = "Internal Mimir service URL (cluster-local)"
  value       = var.mimir.enabled ? "http://mimir.${var.namespace}.svc.cluster.local:8080" : null
}

output "tempo_url" {
  description = "Internal Tempo service URL (cluster-local)"
  value       = var.tempo.enabled ? "http://tempo.${var.namespace}.svc.cluster.local:3100" : null
}

output "prometheus_url" {
  description = "Internal Prometheus service URL (cluster-local)"
  value       = var.prometheus.enabled ? "http://prometheus.${var.namespace}.svc.cluster.local:9090" : null
}

output "pyroscope_url" {
  description = "Internal Pyroscope service URL (cluster-local)"
  value       = var.pyroscope.enabled ? "http://pyroscope.${var.namespace}.svc.cluster.local:4040" : null
}

# --------------------------------
# S3 Bucket Information (AWS Only)
# --------------------------------

output "s3_buckets" {
  description = "S3 bucket names for monitoring components (AWS only)"
  value = var.cloud_provider == "aws" ? {
    loki      = try(aws_s3_bucket.loki[0].id, null)
    mimir     = try(aws_s3_bucket.mimir[0].id, null)
    tempo     = try(aws_s3_bucket.tempo[0].id, null)
    pyroscope = try(aws_s3_bucket.pyroscope[0].id, null)
  } : null
}

output "s3_bucket_arns" {
  description = "S3 bucket ARNs for monitoring components (AWS only)"
  value = var.cloud_provider == "aws" ? {
    loki      = try(aws_s3_bucket.loki[0].arn, null)
    mimir     = try(aws_s3_bucket.mimir[0].arn, null)
    tempo     = try(aws_s3_bucket.tempo[0].arn, null)
    pyroscope = try(aws_s3_bucket.pyroscope[0].arn, null)
  } : null
}

# --------------------------------
# IAM Information (AWS Only)
# --------------------------------

output "iam_role_arn" {
  description = "IAM role ARN for monitoring stack service accounts (AWS IRSA)"
  value       = var.cloud_provider == "aws" && var.aws_config.use_irsa ? try(aws_iam_role.monitoring[0].arn, null) : null
}

output "iam_role_name" {
  description = "IAM role name for monitoring stack service accounts (AWS IRSA)"
  value       = var.cloud_provider == "aws" && var.aws_config.use_irsa ? try(aws_iam_role.monitoring[0].name, null) : null
}

# --------------------------------
# Helm Release Information
# --------------------------------

output "helm_release_name" {
  description = "Name of the Helm release"
  value       = helm_release.monitoring.name
}

output "helm_release_version" {
  description = "Version of the deployed Helm chart"
  value       = helm_release.monitoring.version
}

output "helm_release_status" {
  description = "Status of the Helm release"
  value       = helm_release.monitoring.status
}

# --------------------------------
# Service Accounts (AWS Only)
# --------------------------------

output "service_accounts" {
  description = "Kubernetes service accounts created for IRSA (AWS only)"
  value = var.cloud_provider == "aws" && var.aws_config.use_irsa ? {
    loki      = var.loki.enabled ? try(kubernetes_service_account.loki[0].metadata[0].name, null) : null
    mimir     = var.mimir.enabled ? try(kubernetes_service_account.mimir[0].metadata[0].name, null) : null
    tempo     = var.tempo.enabled ? try(kubernetes_service_account.tempo[0].metadata[0].name, null) : null
    pyroscope = var.pyroscope.enabled ? try(kubernetes_service_account.pyroscope[0].metadata[0].name, null) : null
  } : null
}

# --------------------------------
# Cluster Information
# --------------------------------

output "cluster_name" {
  description = "EKS cluster name where monitoring is deployed"
  value       = var.cluster_name
}

output "region" {
  description = "AWS region where monitoring is deployed"
  value       = var.region
}

# --------------------------------
# Component Status
# --------------------------------

output "enabled_components" {
  description = "List of enabled monitoring components"
  value = [
    for component in ["grafana", "loki", "mimir", "tempo", "prometheus", "pyroscope"] :
    component if try(var[component].enabled, false)
  ]
}
