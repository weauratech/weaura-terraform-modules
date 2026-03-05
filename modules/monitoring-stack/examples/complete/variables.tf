# ============================================================
# Input Variables - Complete Example
# ============================================================

# --------------------------------
# Required Variables
# --------------------------------

variable "tenant_id" {
  description = "Unique tenant identifier (lowercase alphanumeric + hyphens only)"
  type        = string
}

variable "tenant_name" {
  description = "Human-readable tenant name (e.g., 'ACME Corporation')"
  type        = string
}

variable "grafana_domain" {
  description = "Grafana domain for ingress (e.g., grafana.example.com)"
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "monitoring_chart_version" {
  description = "Version of the weaura-monitoring umbrella chart"
  type        = string
}

# --------------------------------
# AWS Configuration
# --------------------------------

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster where monitoring will be deployed"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN for IRSA"
  type        = string
}

variable "eks_oidc_provider_url" {
  description = "EKS OIDC provider URL without https://"
  type        = string
}

# --------------------------------
# Harbor OCI Auth
# --------------------------------

variable "harbor_username" {
  description = "Harbor OCI registry username for pulling the monitoring chart"
  type        = string
  sensitive   = true
  default     = ""
}

variable "harbor_password" {
  description = "Harbor OCI registry password for pulling the monitoring chart"
  type        = string
  sensitive   = true
  default     = ""
}

# --------------------------------
# General Configuration
# --------------------------------

variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
  default     = "production"
}
