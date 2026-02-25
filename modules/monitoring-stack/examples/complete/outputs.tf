# ============================================================
# Output Values - Complete Example
# ============================================================

# --------------------------------
# Grafana Access
# --------------------------------

output "grafana_url" {
  description = "Grafana dashboard URL (internal cluster access)"
  value       = module.monitoring_stack.grafana_url
}

output "grafana_admin_username" {
  description = "Grafana admin username"
  value       = module.monitoring_stack.grafana_admin_username
}

output "grafana_ingress_host" {
  description = "Grafana ingress hostname (if ingress enabled)"
  value       = module.monitoring_stack.grafana_ingress_host
}

output "grafana_port_forward_command" {
  description = "Command to access Grafana via port-forward"
  value       = "kubectl port-forward -n ${var.namespace} svc/grafana 3000:80"
}

# --------------------------------
# Component Endpoints
# --------------------------------

output "loki_url" {
  description = "Loki service URL"
  value       = module.monitoring_stack.loki_url
}

output "mimir_url" {
  description = "Mimir service URL"
  value       = module.monitoring_stack.mimir_url
}

output "tempo_url" {
  description = "Tempo service URL"
  value       = module.monitoring_stack.tempo_url
}

output "prometheus_url" {
  description = "Prometheus service URL"
  value       = module.monitoring_stack.prometheus_url
}

output "pyroscope_url" {
  description = "Pyroscope service URL"
  value       = module.monitoring_stack.pyroscope_url
}

# --------------------------------
# S3 Storage
# --------------------------------

output "s3_buckets" {
  description = "S3 bucket names for each component"
  value       = module.monitoring_stack.s3_buckets
}

output "s3_bucket_arns" {
  description = "S3 bucket ARNs for each component"
  value       = module.monitoring_stack.s3_bucket_arns
}

# --------------------------------
# IAM Resources
# --------------------------------

output "iam_role_arn" {
  description = "IAM role ARN for monitoring service accounts"
  value       = module.monitoring_stack.iam_role_arn
}

output "iam_role_name" {
  description = "IAM role name for monitoring service accounts"
  value       = module.monitoring_stack.iam_role_name
}

# --------------------------------
# Kubernetes Resources
# --------------------------------

output "namespace" {
  description = "Kubernetes namespace"
  value       = module.monitoring_stack.namespace
}

output "service_accounts" {
  description = "Created Kubernetes service accounts"
  value       = module.monitoring_stack.service_accounts
}

# --------------------------------
# Helm Release
# --------------------------------

output "helm_release_name" {
  description = "Helm release name"
  value       = module.monitoring_stack.helm_release_name
}

output "helm_release_version" {
  description = "Deployed chart version"
  value       = module.monitoring_stack.helm_release_version
}

output "helm_release_status" {
  description = "Helm release status"
  value       = module.monitoring_stack.helm_release_status
}

# --------------------------------
# Deployment Summary
# --------------------------------

output "enabled_components" {
  description = "List of enabled monitoring components"
  value       = module.monitoring_stack.enabled_components
}

output "cluster_info" {
  description = "EKS cluster information"
  value = {
    name   = module.monitoring_stack.cluster_name
    region = module.monitoring_stack.region
  }
}

# --------------------------------
# Monitoring & Alerts
# --------------------------------

output "cloudwatch_alarms" {
  description = "CloudWatch alarm names for S3 bucket monitoring"
  value = {
    for k, v in aws_cloudwatch_metric_alarm.s3_bucket_size : k => v.alarm_name
  }
}

output "sns_topic_arn" {
  description = "SNS topic ARN for monitoring alerts (if enabled)"
  value       = var.enable_sns_alerts ? aws_sns_topic.monitoring_alerts[0].arn : null
}

# --------------------------------
# Quick Access Commands
# --------------------------------

output "quick_access_commands" {
  description = "Useful kubectl commands for accessing the monitoring stack"
  value = {
    grafana_port_forward    = "kubectl port-forward -n ${var.namespace} svc/grafana 3000:80"
    prometheus_port_forward = "kubectl port-forward -n ${var.namespace} svc/prometheus 9090:9090"
    list_pods               = "kubectl get pods -n ${var.namespace}"
    list_services           = "kubectl get svc -n ${var.namespace}"
    check_helm_release      = "helm list -n ${var.namespace}"
  }
}
