# ============================================================
# Input Variables - Complete Example
# ============================================================

# --------------------------------
# Required Variables
# --------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster where monitoring will be deployed"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

# --------------------------------
# Harbor Registry Configuration
# --------------------------------

variable "harbor_url" {
  description = "Harbor registry hostname/project (e.g., registry.dev.weaura.ai/weaura-vendorized)"
  type        = string
}

variable "harbor_username" {
  description = "Harbor robot account username for chart pull"
  type        = string
}

variable "harbor_password" {
  description = "Harbor robot account password for chart pull"
  type        = string
  sensitive   = true
}

# --------------------------------
# General Configuration
# --------------------------------

variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
  default     = "production"
}

variable "owner" {
  description = "Owner or team responsible for this infrastructure"
  type        = string
  default     = "platform-team"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "engineering"
}

variable "namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

# --------------------------------
# Sizing & IAM
# --------------------------------

variable "sizing_preset" {
  description = "Sizing preset for monitoring components (small, medium, large, custom)"
  type        = string
  default     = "medium"

  validation {
    condition     = contains(["small", "medium", "large", "custom"], var.sizing_preset)
    error_message = "sizing_preset must be one of: small, medium, large, custom."
  }
}

# --------------------------------
# Grafana Configuration
# --------------------------------

variable "grafana_admin_password" {
  description = "Grafana admin password (use sensitive variable or secrets manager)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "enable_ingress" {
  description = "Enable Ingress for Grafana"
  type        = bool
  default     = false
}

variable "grafana_ingress_host" {
  description = "Hostname for Grafana ingress"
  type        = string
  default     = ""
}

# --------------------------------
# Storage Configuration
# --------------------------------

variable "loki_storage_size" {
  description = "Storage size for Loki"
  type        = string
  default     = "100Gi"
}

variable "loki_retention" {
  description = "Log retention period for Loki"
  type        = string
  default     = "60d"
}

variable "mimir_storage_size" {
  description = "Storage size for Mimir"
  type        = string
  default     = "200Gi"
}

variable "mimir_retention" {
  description = "Metrics retention period for Mimir"
  type        = string
  default     = "180d"
}

variable "tempo_storage_size" {
  description = "Storage size for Tempo"
  type        = string
  default     = "100Gi"
}

variable "tempo_retention" {
  description = "Traces retention period for Tempo (Go duration format, e.g., 168h, 720h)"
  type        = string
  default     = "168h"
}

variable "prometheus_storage_size" {
  description = "Storage size for Prometheus"
  type        = string
  default     = "100Gi"
}

variable "prometheus_retention" {
  description = "Metrics retention period for Prometheus"
  type        = string
  default     = "30d"
}

variable "pyroscope_storage_size" {
  description = "Storage size for Pyroscope"
  type        = string
  default     = "50Gi"
}

# --------------------------------
# S3 Configuration
# --------------------------------

variable "s3_bucket_prefix" {
  description = "Prefix for S3 bucket names (leave empty to use cluster_name-monitoring)"
  type        = string
  default     = ""
}

variable "s3_size_alarm_threshold_gb" {
  description = "S3 bucket size threshold in GB for CloudWatch alarms"
  type        = number
  default     = 500
}

# --------------------------------
# Monitoring & Alerting
# --------------------------------

variable "enable_sns_alerts" {
  description = "Enable SNS topic for monitoring alerts"
  type        = bool
  default     = false
}

variable "alert_email" {
  description = "Email address for monitoring alerts"
  type        = string
  default     = ""
}

# --------------------------------
# Advanced Configuration
# --------------------------------

variable "additional_helm_values" {
  description = "Additional Helm values to merge with defaults"
  type        = map(any)
  default     = {}
}
