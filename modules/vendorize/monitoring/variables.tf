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
# Harbor Configuration
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

variable "chart_version" {
  description = "Version of weaura-monitoring chart to deploy"
  type        = string
  default     = "0.15.0"
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

variable "sizing_preset" {
  description = "Sizing preset for monitoring components. 'custom' uses individual component settings. Options: small (dev/test), medium (staging/small-prod), large (production)."
  type        = string
  default     = "custom"

  validation {
    condition     = contains(["small", "medium", "large", "custom"], var.sizing_preset)
    error_message = "sizing_preset must be one of: small, medium, large, custom."
  }
}

variable "iam_mode" {
  description = "IAM strategy for service accounts (irsa = OIDC-based, pod_identity = EKS Pod Identity)"
  type        = string
  default     = "irsa"
  validation {
    condition     = contains(["irsa", "pod_identity"], var.iam_mode)
    error_message = "iam_mode must be one of: irsa, pod_identity"
  }
}

# --------------------------------
# AWS-Specific Configuration
# --------------------------------

variable "aws_config" {
  description = "AWS-specific configuration. NOTE: use_irsa is DEPRECATED — use standalone iam_mode variable instead."
  type = object({
    s3_bucket_prefix = optional(string, "")
    use_irsa         = optional(bool, null) # DEPRECATED: use iam_mode instead. Kept for backwards compatibility.
  })
  default = {}
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

  validation {
    condition     = can(regex("^[0-9]+(h|d|w|m|s)$", var.loki.retention))
    error_message = "Loki retention must be in duration format (e.g., '30d', '24h', '7d'). Supported units: h (hours), d (days), w (weeks), m (months), s (seconds)."
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

  validation {
    condition     = can(regex("^[0-9]+(h|d|w|m|s)$", var.mimir.retention))
    error_message = "Mimir retention must be in duration format (e.g., '90d', '168h', '30d'). Supported units: h (hours), d (days), w (weeks), m (months), s (seconds)."
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
    retention    = optional(string, "720h")
  })
  default = {
    enabled      = true
    storage_size = "50Gi"
    retention    = "720h"
  }

  validation {
    condition     = can(regex("^[0-9]+(h|d|w|m|s)$", var.tempo.retention))
    error_message = "Tempo retention must be in Go duration format (e.g., '720h', '168h', '24h'). Supported units: h (hours), d (days), w (weeks), m (months), s (seconds)."
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
# Enterprise Features
# --------------------------------

variable "pdb_enabled" {
  description = "Enable PodDisruptionBudgets for all components"
  type        = bool
  default     = false
}

variable "alert_rules_enabled" {
  description = "Enable built-in alerting rules"
  type        = bool
  default     = false
}

variable "alert_rules" {
  description = "Alert rules configuration"
  type = object({
    component_down  = optional(bool, true)
    disk_pressure   = optional(bool, true)
    memory_pressure = optional(bool, true)
    high_error_rate = optional(bool, true)
    replication_lag = optional(bool, true)
  })
  default = {}
}

variable "network_policy_enabled" {
  description = "Enable NetworkPolicies for inter-component traffic"
  type        = bool
  default     = false
}

variable "network_policy_allowed_namespaces" {
  description = "List of namespaces allowed to access monitoring components"
  type        = list(string)
  default     = []
}

variable "tls_enabled" {
  description = "Enable TLS for inter-component communication"
  type        = bool
  default     = false
}

variable "tls_cert_manager" {
  description = "cert-manager configuration for TLS"
  type = object({
    enabled = optional(bool, false)
    issuer_ref = optional(object({
      name = optional(string, "")
      kind = optional(string, "ClusterIssuer")
    }), {})
  })
  default = {}
}

variable "alertmanager_enabled" {
  description = "Enable Alertmanager integration"
  type        = bool
  default     = false
}

variable "alertmanager_receivers" {
  description = "Alertmanager receiver configuration"
  type = object({
    webhook = optional(object({
      enabled = optional(bool, false)
      url     = optional(string, "")
    }), {})
    email = optional(object({
      enabled   = optional(bool, false)
      to        = optional(string, "")
      from      = optional(string, "")
      smarthost = optional(string, "")
    }), {})
  })
  default = {}
}

variable "service_monitor_auto_enable" {
  description = "Automatically enable ServiceMonitors for all components"
  type        = bool
  default     = false
}

variable "memberlist_cluster_label" {
  description = "Label for memberlist cluster grouping (empty = default behavior)"
  type        = string
  default     = ""
}

# --------------------------------
# Additional Configuration
# --------------------------------

variable "helm_values" {
  description = "Additional Helm values to merge with defaults"
  type        = map(any)
  default     = {}
}

variable "helm_timeout" {
  description = "Timeout in seconds for Helm release operations. Increase for EKS Auto Mode greenfield deployments where cold-start compute provisioning adds latency."
  type        = number
  default     = 1800

  validation {
    condition     = var.helm_timeout >= 300 && var.helm_timeout <= 7200
    error_message = "helm_timeout must be between 300 (5 min) and 7200 (2 hours)."
  }
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}
