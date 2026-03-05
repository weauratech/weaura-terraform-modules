# ============================================================
# Input Variables — Greenfield Deployment
# ============================================================

# --------------------------------
# Project Identity
# --------------------------------

variable "project_name" {
  description = "Name used for VPC, EKS cluster, S3 prefixes, and resource tagging"
  type        = string
}

variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Deployment environment (used in default_tags)"
  type        = string
  default     = "development"
}

# --------------------------------
# Networking
# --------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones for subnet distribution"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

# --------------------------------
# EKS Configuration
# --------------------------------

variable "enable_auto_mode" {
  description = "Enable EKS Auto Mode (uses pod_identity; disables managed node groups)"
  type        = bool
  default     = false
}

# --------------------------------
# Monitoring Configuration
# --------------------------------

variable "sizing_preset" {
  description = "Sizing preset for monitoring components: small, medium, large, or custom"
  type        = string
  default     = "small"
}

# --------------------------------
# Harbor Registry
# --------------------------------

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
# Grafana
# --------------------------------

variable "grafana_admin_password" {
  description = "Grafana admin password (change from default in production)"
  type        = string
  sensitive   = true
  default     = "admin"
}

# --------------------------------
# Tags
# --------------------------------

variable "tags" {
  description = "Additional tags applied to all resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Project   = "vendorize"
  }
}
