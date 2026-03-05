# --------------------------------
# Required Variables
# --------------------------------

variable "project_name" {
  description = "Project name used for resource naming (VPC, EKS cluster, S3 buckets)"
  type        = string
}

variable "region" {
  description = "AWS region for all resources"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones (minimum 2 recommended)"
  type        = list(string)
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

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

# --------------------------------
# VPC Configuration
# --------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# --------------------------------
# EKS Configuration
# --------------------------------

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.35"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 5
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.xlarge"]
}

variable "node_disk_size" {
  description = "Root volume size in GiB for worker nodes"
  type        = number
  default     = 50
}

# --------------------------------
# Monitoring Configuration
# --------------------------------

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "sizing_preset" {
  description = "Sizing preset: small (dev), medium (staging), large (production)"
  type        = string
  default     = "large"
}

variable "grafana_ingress_enabled" {
  description = "Enable Kubernetes Ingress for Grafana"
  type        = bool
  default     = false
}

variable "grafana_ingress_host" {
  description = "Hostname for Grafana Ingress"
  type        = string
  default     = ""
}

# --------------------------------
# Tags
# --------------------------------

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
