# ============================================================
# Variables - Grafana OSS Module (Multi-Cloud)
# ============================================================
# Input variables for the observability module.
# Supports AWS cloud provider.
# ============================================================

# ============================================================
# VENDORIZATION VARIABLES (WeAura White-Label Distribution)
# ============================================================
# These variables enable tenant isolation, branding customization,
# and retention policy configuration for multi-tenant deployments.
# ============================================================

# Tenant Identification - REQUIRED
variable "tenant_id" {
  description = "Unique tenant identifier (lowercase alphanumeric + hyphens only). Used for S3 bucket paths, namespace naming, IAM role naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.tenant_id))
    error_message = "tenant_id must be lowercase alphanumeric with hyphens only (e.g., 'acme-corp', 'client-123')."
  }
}

variable "tenant_name" {
  description = "Human-readable tenant name (e.g., 'ACME Corporation'). Used for resource tagging and documentation."
  type        = string

  validation {
    condition     = length(var.tenant_name) > 0 && length(var.tenant_name) <= 100
    error_message = "tenant_name must be between 1 and 100 characters."
  }
}

# Branding Variables - OPTIONAL
variable "branding_app_title" {
  description = "Grafana browser tab title and header title (grafana.ini: server.app_title)."
  type        = string
  default     = "Grafana"
}

variable "branding_app_name" {
  description = "Grafana application name shown in UI (grafana.ini: server.app_name)."
  type        = string
  default     = "Grafana"
}

variable "branding_login_title" {
  description = "Login page title text."
  type        = string
  default     = "Welcome"
}

variable "branding_logo_url" {
  description = "URL to custom logo image (SVG/PNG/JPG). Empty string disables logo replacement."
  type        = string
  default     = ""
}

variable "branding_css_overrides" {
  description = "Custom CSS overrides for additional branding. Empty string disables CSS customization."
  type        = string
  default     = ""
}

# Retention Policy Variables - OPTIONAL (all in hours)
variable "retention_loki_hours" {
  description = "Loki logs retention period in hours (default: 720 = 30 days)."
  type        = number
  default     = 720
}

variable "retention_mimir_hours" {
  description = "Mimir metrics retention period in hours (default: 2160 = 90 days)."
  type        = number
  default     = 2160
}

variable "retention_tempo_hours" {
  description = "Tempo traces retention period in hours (default: 168 = 7 days)."
  type        = number
  default     = 168
}

variable "retention_pyroscope_hours" {
  description = "Pyroscope profiles retention period in hours (default: 720 = 30 days)."
  type        = number
  default     = 720
}

# Infrastructure Configuration - OPTIONAL
variable "secrets_provider" {
  description = "Secrets management provider: 'kubernetes' (plain Secrets) or 'external-secrets' (External Secrets Operator)."
  type        = string
  default     = "kubernetes"

  validation {
    condition     = contains(["kubernetes", "external-secrets"], var.secrets_provider)
    error_message = "secrets_provider must be 'kubernetes' or 'external-secrets'."
  }
}

variable "database_type" {
  description = "Grafana database type: 'sqlite' (default, single-pod only) or 'postgres' (required for HA)."
  type        = string
  default     = "sqlite"

  validation {
    condition     = contains(["sqlite", "postgres"], var.database_type)
    error_message = "database_type must be 'sqlite' or 'postgres'."
  }
}

# ============================================================
# CLOUD PROVIDER SELECTION
# ============================================================

variable "cloud_provider" {
  description = "Cloud provider to deploy to (aws)"
  type        = string

  validation {
    condition     = contains(["aws"], var.cloud_provider)
    error_message = "cloud_provider must be 'aws'."
  }
}

# ============================================================
# COMPONENT TOGGLES
# ============================================================

variable "enable_log_collector" {
  description = "Enable Promtail log collector to ship logs to Loki"
  type        = bool
  default     = false
}

variable "log_collector_target_namespaces" {
  description = "List of Kubernetes namespaces to collect logs from. Empty means all namespaces."
  type        = list(string)
  default     = []
}

variable "promtail_chart_version" {
  description = "Promtail Helm chart version"
  type        = string
  default     = "6.16.6"
}

variable "enable_grafana" {
  description = "Enable Grafana deployment"
  type        = bool
  default     = true
}

variable "enable_prometheus" {
  description = "Enable Prometheus (kube-prometheus-stack) deployment"
  type        = bool
  default     = true
}

variable "enable_loki" {
  description = "Enable Loki deployment"
  type        = bool
  default     = true
}

variable "enable_mimir" {
  description = "Enable Mimir deployment"
  type        = bool
  default     = true
}

variable "enable_tempo" {
  description = "Enable Tempo deployment"
  type        = bool
  default     = true
}

variable "enable_pyroscope" {
  description = "Enable Pyroscope deployment"
  type        = bool
  default     = true
}

variable "enable_resource_quotas" {
  description = "Enable Kubernetes ResourceQuotas for each namespace. Disabled by default to avoid conflicts with Helm atomic deployments."
  type        = bool
  default     = false
}

variable "enable_limit_ranges" {
  description = "Enable Kubernetes LimitRanges for each namespace"
  type        = bool
  default     = true
}

variable "enable_network_policies" {
  description = "Enable Kubernetes NetworkPolicies for each namespace"
  type        = bool
  default     = true
}

# ============================================================
# ENVIRONMENT & NAMING
# ============================================================

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

variable "project" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "observability"
}

variable "name_prefix" {
  description = "Prefix for all resource names (defaults to project name)"
  type        = string
  default     = ""
}

# ============================================================
# AWS CONFIGURATION
# ============================================================

variable "aws_region" {
  description = "AWS region (required when cloud_provider is 'aws')"
  type        = string
  default     = "us-east-1"
}

variable "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN for IRSA (required when cloud_provider is 'aws')"
  type        = string
  default     = ""
}

variable "eks_oidc_provider_url" {
  description = "EKS OIDC provider URL without https:// (required when cloud_provider is 'aws')"
  type        = string
  default     = ""
}

variable "eks_cluster_name" {
  description = "EKS cluster name (required when cloud_provider is 'aws')"
  type        = string
  default     = ""
}

# ============================================================
# ============================================================







# ============================================================
# STORAGE CONFIGURATION
# ============================================================

variable "create_storage" {
  description = "Create storage resources (S3 buckets for AWS)"
  type        = bool
  default     = true
}

variable "storage_class" {
  description = "Kubernetes StorageClass for persistent volumes"
  type        = string
  default     = "gp3"
}

# AWS S3 Bucket Names
variable "s3_bucket_prefix" {
  description = "Prefix for S3 bucket names (AWS only)"
  type        = string
  default     = ""
}

variable "s3_kms_key_arn" {
  description = "KMS key ARN for S3 bucket encryption. If empty, uses AES256 (AWS-managed keys). Providing a CMK improves security posture."
  type        = string
  default     = ""
}

variable "s3_buckets" {
  description = "S3 bucket names for each component (AWS only, optional if create_storage is true)"
  type = object({
    loki_chunks  = optional(string, "")
    loki_ruler   = optional(string, "")
    mimir_blocks = optional(string, "")
    mimir_ruler  = optional(string, "")
    tempo        = optional(string, "")
  })
  default = {}
}





# ============================================================
# SECRETS CONFIGURATION
# ============================================================

# AWS Secrets Manager
variable "aws_secrets_path_prefix" {
  description = "Prefix for AWS Secrets Manager paths (AWS only)"
  type        = string
  default     = ""
}

variable "aws_secrets_path_slack_webhooks" {
  description = "AWS Secrets Manager path for Slack webhooks (AWS + Slack only)"
  type        = string
  default     = ""
}

variable "aws_secrets_path_grafana_admin" {
  description = "AWS Secrets Manager path for Grafana admin password (AWS only)"
  type        = string
  default     = ""
}





# ============================================================
# GRAFANA CONFIGURATION
# ============================================================

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "grafana_persistence_enabled" {
  description = "Enable persistent storage for Grafana"
  type        = bool
  default     = true
}

variable "grafana_chart_version" {
  description = "Grafana Helm chart version"
  type        = string
  default     = "10.3.1"
}

variable "grafana_domain" {
  description = "Grafana domain for ingress"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.grafana_domain))
    error_message = "Grafana domain must be a valid DNS hostname."
  }
}

variable "grafana_base_url" {
  description = "Base URL for Grafana (for alert action links). Defaults to https://<grafana_domain>"
  type        = string
  default     = ""
}

variable "grafana_storage_size" {
  description = "Grafana PVC size"
  type        = string
  default     = "40Gi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi|Ti)$", var.grafana_storage_size))
    error_message = "Storage size must be in Kubernetes format (e.g., '512Mi', '40Gi', '1Ti')."
  }
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "grafana_plugins" {
  description = "List of Grafana plugins to install"
  type        = list(string)
  default     = ["grafana-lokiexplore-app", "grafana-clock-panel", "grafana-k8s-app"]
}

variable "grafana_node_selector" {
  description = "Node selector for Grafana pods"
  type        = map(string)
  default     = {}
}

variable "grafana_resources" {
  description = "Resource requests and limits for Grafana"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "200m"
      memory = "512Mi"
    }
    limits = {
      cpu    = "1000m"
      memory = "1Gi"
    }
  }
}

# ============================================================
# GRAFANA SSO CONFIGURATION
# ============================================================

variable "grafana_sso_enabled" {
  description = "Enable SSO authentication for Grafana"
  type        = bool
  default     = false
}

variable "grafana_sso_provider" {
  description = "SSO provider (google, okta, github)"
  type        = string
  default     = "google"

  validation {
    condition     = contains(["google", "okta", "github"], var.grafana_sso_provider)
    error_message = "SSO provider must be one of: google, okta, github."
  }
}

variable "grafana_sso_client_id" {
  description = "SSO OAuth Client ID"
  type        = string
  sensitive   = true
  default     = ""
}

variable "grafana_sso_client_secret" {
  description = "SSO OAuth Client Secret"
  type        = string
  sensitive   = true
  default     = ""
}

variable "grafana_sso_allowed_domains" {
  description = "Allowed domains for SSO (comma-separated)"
  type        = string
  default     = ""
}

variable "grafana_sso_allowed_organizations" {
  description = "Allowed organizations for GitHub SSO (comma-separated)"
  type        = string
  default     = ""
}

variable "grafana_oauth_auth_url" {
  description = "OAuth authorization URL"
  type        = string
  default     = ""
}

variable "grafana_oauth_token_url" {
  description = "OAuth token URL"
  type        = string
  default     = ""
}

variable "grafana_oauth_api_url" {
  description = "OAuth API/userinfo URL"
  type        = string
  default     = ""
}

variable "grafana_oauth_role_attribute_path" {
  description = "JMESPath expression for role mapping"
  type        = string
  default     = "contains(groups[*], 'admins') && 'GrafanaAdmin' || 'Viewer'"
}

variable "grafana_sso_team_ids" {
  description = "Team IDs for SSO team-based role mapping (comma-separated)"
  type        = string
  default     = ""
}

variable "grafana_sso_allow_assign_grafana_admin" {
  description = "Allow SSO role mapping to assign Grafana Server Admin"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_datasource" {
  description = "Enable CloudWatch datasource in Grafana (AWS only)"
  type        = bool
  default     = false
}


variable "grafana_enable_alerting" {
  description = "Enable Grafana Unified Alerting"
  type        = bool
  default     = true
}

# ============================================================
# PROMETHEUS CONFIGURATION
# ============================================================

variable "prometheus_chart_version" {
  description = "kube-prometheus-stack Helm chart version"
  type        = string
  default     = "68.2.1"
}

variable "prometheus_retention" {
  description = "Local retention period for Prometheus"
  type        = string
  default     = "7d"
}

variable "prometheus_retention_size" {
  description = "Maximum size of Prometheus TSDB"
  type        = string
  default     = "50GB"
}

variable "prometheus_enable_node_exporter" {
  description = "Enable node-exporter in kube-prometheus-stack"
  type        = bool
  default     = true
}

variable "prometheus_enable_kube_state_metrics" {
  description = "Enable kube-state-metrics in kube-prometheus-stack"
  type        = bool
  default     = true
}

variable "prometheus_service_monitor_selector" {
  description = "ServiceMonitor selector labels"
  type        = map(string)
  default     = {}
}

variable "prometheus_storage_size" {
  description = "Prometheus PVC size"
  type        = string
  default     = "80Gi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi|Ti)$", var.prometheus_storage_size))
    error_message = "Storage size must be in Kubernetes format."
  }
}

variable "prometheus_resources" {
  description = "Resource requests and limits for Prometheus"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "500m"
      memory = "2Gi"
    }
    limits = {
      cpu    = "2000m"
      memory = "4Gi"
    }
  }
}

# ============================================================
# LOKI CONFIGURATION
# ============================================================

variable "loki_chart_version" {
  description = "Loki Helm chart version"
  type        = string
  default     = "6.48.0"
}

variable "loki_retention_period" {
  description = "Loki log retention period"
  type        = string
  default     = "744h"
}

variable "loki_replicas" {
  description = "Number of replicas for Loki components"
  type = object({
    write   = number
    read    = number
    backend = number
  })
  default = {
    write   = 3
    read    = 3
    backend = 3
  }
}

variable "loki_deployment_mode" {
  description = "Loki deployment mode: 'SingleBinary' for small/lightweight deployments (single loki-0 pod), 'SimpleScalable' for medium+ deployments (separate write, read, backend pods with caches)."
  type        = string
  default     = "SingleBinary"

  validation {
    condition     = contains(["SingleBinary", "SimpleScalable"], var.loki_deployment_mode)
    error_message = "loki_deployment_mode must be 'SingleBinary' or 'SimpleScalable'."
  }
}

variable "loki_resources" {
  description = "Resource requests and limits for Loki components"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "100m"
      memory = "256Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "512Mi"
    }
  }
}

# ============================================================
# MIMIR CONFIGURATION
# ============================================================

variable "mimir_chart_version" {
  description = "Mimir Helm chart version"
  type        = string
  default     = "6.0.5"
}

variable "mimir_replication_factor" {
  description = "Replication factor for Mimir ingesters"
  type        = number
  default     = 1
}

variable "mimir_retention_period" {
  description = "Mimir metrics retention period"
  type        = string
  default     = "365d"
}

variable "mimir_resources" {
  description = "Resource requests and limits for Mimir components"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "100m"
      memory = "256Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "1Gi"
    }
  }
}

# ============================================================
# TEMPO CONFIGURATION
# ============================================================

variable "tempo_chart_version" {
  description = "Tempo Helm chart version"
  type        = string
  default     = "1.61.3"
}

variable "tempo_retention_period" {
  description = "Tempo traces retention period"
  type        = string
  default     = "168h"
}

variable "tempo_resources" {
  description = "Resource requests and limits for Tempo components"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "100m"
      memory = "256Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "512Mi"
    }
  }
}

# ============================================================
# PYROSCOPE CONFIGURATION
# ============================================================

variable "pyroscope_chart_version" {
  description = "Pyroscope Helm chart version"
  type        = string
  default     = "1.18.1"
}

variable "pyroscope_replicas" {
  description = "Number of Pyroscope replicas"
  type        = number
  default     = 1
}

variable "pyroscope_persistence_size" {
  description = "Pyroscope PVC size"
  type        = string
  default     = "50Gi"
}

variable "pyroscope_enable_alloy" {
  description = "Enable Grafana Alloy agent for Pyroscope"
  type        = bool
  default     = true
}

variable "excluded_profiling_namespaces" {
  description = "List of namespaces to exclude from profiling"
  type        = list(string)
  default     = ["kube-system", "kube-public", "kube-node-lease", "cert-manager", "ingress-nginx"]
}

variable "pyroscope_resources" {
  description = "Resource requests and limits for Pyroscope"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "100m"
      memory = "256Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "512Mi"
    }
  }
}

# ============================================================
# INGRESS CONFIGURATION
# ============================================================

variable "enable_ingress" {
  description = "Enable ingress for Grafana"
  type        = bool
  default     = true
}

variable "enable_tls" {
  description = "Enable TLS for ingress"
  type        = bool
  default     = true
}

variable "cluster_issuer" {
  description = "Cert-manager cluster issuer name"
  type        = string
  default     = "letsencrypt-prod"
}

variable "ingress_class" {
  description = "Ingress class name (e.g., nginx, nginx-private)"
  type        = string
  default     = "nginx"
}

variable "ingress_annotations" {
  description = "Additional annotations for ingress resources"
  type        = map(string)
  default     = {}
}

variable "tls_secret_name" {
  description = "Name of the TLS secret for ingress (if using cert-manager or pre-created secret)"
  type        = string
  default     = ""
}

# External Secrets for TLS (AWS Secrets Manager)
variable "enable_tls_external_secret" {
  description = "Enable creation of ExternalSecret for TLS certificate sync from AWS Secrets Manager"
  type        = bool
  default     = false
}

variable "tls_external_secret_config" {
  description = "Configuration for TLS ExternalSecret"
  type = object({
    cluster_secret_store_name = optional(string, "")
    key_vault_cert_name       = optional(string, "")
    secret_refresh_interval   = optional(string, "1h")
  })
  default = {}
}

# AWS-specific ingress
variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS (AWS ALB ingress only)"
  type        = string
  default     = ""
}

variable "ingress_scheme" {
  description = "ALB scheme - internal or internet-facing (AWS ALB ingress only)"
  type        = string
  default     = "internal"

  validation {
    condition     = contains(["internal", "internet-facing"], var.ingress_scheme)
    error_message = "Ingress scheme must be 'internal' or 'internet-facing'."
  }
}

# ============================================================
# ALERTING CONFIGURATION
# ============================================================

variable "alerting_provider" {
  description = "Alerting provider (slack or teams)"
  type        = string
  default     = "slack"

  validation {
    condition     = contains(["slack", "none"], var.alerting_provider)
    error_message = "alerting_provider must be 'slack' or 'none'."
  }
}

# Slack Configuration
variable "slack_webhook_general" {
  description = "Slack webhook URL for general alerts"
  type        = string
  sensitive   = true
  default     = ""
}

variable "slack_webhook_critical" {
  description = "Slack webhook URL for critical alerts"
  type        = string
  sensitive   = true
  default     = ""
}

variable "slack_webhook_infrastructure" {
  description = "Slack webhook URL for infrastructure alerts"
  type        = string
  sensitive   = true
  default     = ""
}

variable "slack_webhook_application" {
  description = "Slack webhook URL for application alerts"
  type        = string
  sensitive   = true
  default     = ""
}

variable "slack_channel_general" {
  description = "Slack channel for general alerts"
  type        = string
  default     = "#alerts-general"
}

variable "slack_channel_critical" {
  description = "Slack channel for critical alerts"
  type        = string
  default     = "#alerts-critical"
}

variable "slack_channel_infrastructure" {
  description = "Slack channel for infrastructure alerts"
  type        = string
  default     = "#alerts-infrastructure"
}

variable "slack_channel_application" {
  description = "Slack channel for application alerts"
  type        = string
  default     = "#alerts-application"
}

# Microsoft Teams Configuration




# ============================================================
# GRAFANA DASHBOARDS & FOLDERS
# ============================================================

variable "dashboards_path" {
  description = "Path to dashboards directory. If empty, dashboard provisioning is disabled."
  type        = string
  default     = ""
}

variable "grafana_folders" {
  description = "Map of Grafana folders to create. Key is the folder UID."
  type = map(object({
    title            = string
    dashboard_subdir = optional(string, "")
  }))
  default = {}
}

# ============================================================
# TAGS & LABELS
# ============================================================

variable "tags" {
  description = "Additional tags to apply to all cloud resources"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Additional labels to apply to all Kubernetes resources"
  type        = map(string)
  default     = {}
}

# ============================================================
# NODE SCHEDULING CONFIGURATION
# ============================================================

variable "global_node_selector" {
  description = "Node selector applied to all observability components"
  type        = map(string)
  default     = {}
}

variable "global_tolerations" {
  description = "Tolerations applied to all observability components"
  type = list(object({
    key      = string
    operator = string
    value    = optional(string)
    effect   = string
  }))
  default = []
}

# ============================================================
# GRAFANA RESOURCES TOGGLE
# ============================================================

variable "enable_grafana_resources" {
  description = "Enable Grafana resources (folders, alerting, dashboards). Set to false for initial deploy when Grafana is not yet accessible from the pipeline agent."
  type        = bool
  default     = false
}

# ============================================================
# MONITORING UMBRELLA CHART CONFIGURATION
# ============================================================

variable "monitoring_namespace" {
  description = "Namespace for the umbrella monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "monitoring_chart_version" {
  description = "Version of the weaura-monitoring umbrella chart"
  type        = string
}

variable "monitoring_chart_repository" {
  description = "OCI repository URL for the weaura-monitoring umbrella chart"
  type        = string
  default     = "oci://registry.dev.weaura.ai/weaura-vendorized"
}

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
