# ============================================================
# Input Variables
# ============================================================

# --------------------------------
# Required Variables
# --------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster where monitoring will be deployed"
  type        = string
}

variable "region" {
  description = "AWS region of the EKS cluster"
  type        = string
}

# --------------------------------
# ECR Configuration (WeAura Account)
# --------------------------------

variable "ecr_account_id" {
  description = "AWS account ID where WeAura charts are stored"
  type        = string
  default     = "950242546328"
}

variable "ecr_region" {
  description = "AWS region where WeAura ECR is located"
  type        = string
  default     = "us-east-2"
}

variable "chart_version" {
  description = "Version of weaura-monitoring chart to deploy"
  type        = string
  default     = "0.1.0"
}

# --------------------------------
# Kubernetes Configuration
# --------------------------------

variable "namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "create_namespace" {
  description = "Create namespace if it doesn't exist"
  type        = bool
  default     = true
}

# --------------------------------
# Cloud Provider Selection
# --------------------------------

variable "cloud_provider" {
  description = "Cloud provider (aws or azure)"
  type        = string
  default     = "aws"

  validation {
    condition     = contains(["aws", "azure"], var.cloud_provider)
    error_message = "cloud_provider must be either 'aws' or 'azure'."
  }
}

# --------------------------------
# AWS-Specific Configuration
# --------------------------------

variable "aws_config" {
  description = "AWS-specific configuration for monitoring stack"
  type = object({
    s3_bucket_prefix = optional(string, "")
    use_irsa         = optional(bool, true)
  })
  default = {
    s3_bucket_prefix = ""
    use_irsa         = true
  }
}

# --------------------------------
# Grafana Configuration
# --------------------------------

variable "grafana" {
  description = "Grafana configuration"
  type = object({
    enabled             = optional(bool, true)
    admin_password      = optional(string, "")
    ingress_enabled     = optional(bool, false)
    ingress_host        = optional(string, "")
    storage_size        = optional(string, "10Gi")
    persistence_enabled = optional(bool, true)
  })
  default = {
    enabled             = true
    admin_password      = ""
    ingress_enabled     = false
    ingress_host        = ""
    storage_size        = "10Gi"
    persistence_enabled = true
  }
}

# --------------------------------
# Loki Configuration
# --------------------------------

variable "loki" {
  description = "Loki configuration"
  type = object({
    enabled      = optional(bool, true)
    storage_size = optional(string, "50Gi")
    retention    = optional(string, "30d")
  })
  default = {
    enabled      = true
    storage_size = "50Gi"
    retention    = "30d"
  }
}

# --------------------------------
# Mimir Configuration
# --------------------------------

variable "mimir" {
  description = "Mimir configuration"
  type = object({
    enabled      = optional(bool, true)
    storage_size = optional(string, "100Gi")
    retention    = optional(string, "90d")
  })
  default = {
    enabled      = true
    storage_size = "100Gi"
    retention    = "90d"
  }
}

# --------------------------------
# Tempo Configuration
# --------------------------------

variable "tempo" {
  description = "Tempo configuration"
  type = object({
    enabled      = optional(bool, true)
    storage_size = optional(string, "50Gi")
    retention    = optional(string, "30d")
  })
  default = {
    enabled      = true
    storage_size = "50Gi"
    retention    = "30d"
  }
}

# --------------------------------
# Prometheus Configuration
# --------------------------------

variable "prometheus" {
  description = "Prometheus configuration"
  type = object({
    enabled      = optional(bool, true)
    storage_size = optional(string, "50Gi")
    retention    = optional(string, "15d")
  })
  default = {
    enabled      = true
    storage_size = "50Gi"
    retention    = "15d"
  }
}

# --------------------------------
# Pyroscope Configuration
# --------------------------------

variable "pyroscope" {
  description = "Pyroscope configuration"
  type = object({
    enabled      = optional(bool, true)
    storage_size = optional(string, "30Gi")
  })
  default = {
    enabled      = true
    storage_size = "30Gi"
  }
}

# --------------------------------
# Additional Configuration
# --------------------------------

variable "helm_values" {
  description = "Additional Helm values to merge with defaults"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}
