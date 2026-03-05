# --------------------------------
# Required Variables
# --------------------------------

variable "cluster_name" {
  description = "Name of the existing EKS cluster"
  type        = string
}

variable "region" {
  description = "AWS region of the EKS cluster"
  type        = string
}

variable "harbor_url" {
  description = "Harbor registry URL (e.g., registry.dev.weaura.ai/weaura-vendorized)"
  type        = string
}

variable "harbor_username" {
  description = "Harbor robot account username"
  type        = string
}

variable "harbor_password" {
  description = "Harbor robot account password"
  type        = string
  sensitive   = true
}

# --------------------------------
# Deployment Configuration
# --------------------------------

variable "environment" {
  description = "Deployment environment (e.g., production, staging)"
  type        = string
  default     = "production"
}

variable "namespace" {
  description = "Kubernetes namespace for the monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "sizing_preset" {
  description = "Sizing preset: small (dev), medium (staging), large (production)"
  type        = string
  default     = "medium"
}

variable "s3_bucket_prefix" {
  description = "Prefix for S3 bucket names (defaults to cluster_name-monitoring)"
  type        = string
  default     = ""
}

# --------------------------------
# Grafana Configuration
# --------------------------------

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "grafana_ingress_enabled" {
  description = "Enable Kubernetes Ingress for Grafana"
  type        = bool
  default     = true
}

variable "grafana_ingress_host" {
  description = "Hostname for Grafana Ingress (e.g., grafana.example.com)"
  type        = string
  default     = ""
}

# --------------------------------
# Component Retention & Storage
# --------------------------------

variable "loki_storage_size" {
  description = "Loki persistent volume size"
  type        = string
  default     = "50Gi"
}

variable "loki_retention" {
  description = "Loki log retention period"
  type        = string
  default     = "30d"
}

variable "mimir_storage_size" {
  description = "Mimir persistent volume size"
  type        = string
  default     = "100Gi"
}

variable "mimir_retention" {
  description = "Mimir metrics retention period"
  type        = string
  default     = "90d"
}

variable "tempo_storage_size" {
  description = "Tempo persistent volume size"
  type        = string
  default     = "50Gi"
}

variable "tempo_retention" {
  description = "Tempo traces retention period (Go duration format)"
  type        = string
  default     = "720h"
}

variable "prometheus_storage_size" {
  description = "Prometheus persistent volume size"
  type        = string
  default     = "50Gi"
}

variable "prometheus_retention" {
  description = "Prometheus metrics retention period"
  type        = string
  default     = "15d"
}

variable "pyroscope_storage_size" {
  description = "Pyroscope persistent volume size"
  type        = string
  default     = "30Gi"
}

# --------------------------------
# Optional Configuration
# --------------------------------

variable "additional_helm_values" {
  description = "Additional Helm values to merge with defaults"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}
