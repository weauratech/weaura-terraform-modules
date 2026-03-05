# ============================================================
# Outputs — Greenfield Deployment
# ============================================================

# --------------------------------
# VPC
# --------------------------------

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# --------------------------------
# EKS
# --------------------------------

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL for the EKS cluster"
  value       = module.eks.cluster_oidc_issuer
}

output "auto_mode_enabled" {
  description = "Whether EKS Auto Mode is enabled"
  value       = module.eks.auto_mode_enabled
}

# --------------------------------
# Monitoring Stack
# --------------------------------

output "grafana_url" {
  description = "Internal Grafana service URL"
  value       = module.monitoring.grafana_url
}

output "monitoring_namespace" {
  description = "Kubernetes namespace where monitoring is deployed"
  value       = module.monitoring.namespace
}

output "iam_mode" {
  description = "Active IAM strategy (irsa or pod_identity)"
  value       = module.monitoring.iam_mode
}

output "s3_buckets" {
  description = "S3 bucket names for monitoring components"
  value       = module.monitoring.s3_buckets
}

output "helm_release_status" {
  description = "Status of the monitoring Helm release"
  value       = module.monitoring.helm_release_status
}

output "enabled_components" {
  description = "List of enabled monitoring components"
  value       = module.monitoring.enabled_components
}

output "sizing_preset" {
  description = "Active sizing preset for the monitoring stack"
  value       = module.monitoring.sizing_preset
}
