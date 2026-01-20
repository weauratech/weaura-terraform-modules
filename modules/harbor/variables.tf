# ============================================================
# Variables - Harbor Container Registry Module
# ============================================================
# Input variables for Harbor deployment on AWS EKS.
# ============================================================

# ============================================================
# CLOUD PROVIDER CONFIGURATION
# ============================================================

variable "cloud_provider" {
  description = "Cloud provider to deploy to (currently only AWS is supported)"
  type        = string
  default     = "aws"

  validation {
    condition     = contains(["aws"], var.cloud_provider)
    error_message = "Currently only 'aws' is supported for Harbor deployment."
  }
}

# ============================================================
# GENERAL CONFIGURATION
# ============================================================

variable "project" {
  description = "Project name for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, production."
  }
}

variable "name_prefix" {
  description = "Prefix for resource naming (defaults to project name if empty)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Additional Kubernetes labels to apply to resources"
  type        = map(string)
  default     = {}
}

# ============================================================
# AWS CONFIGURATION
# ============================================================

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider for IRSA"
  type        = string
}

variable "eks_oidc_provider_url" {
  description = "URL of the EKS OIDC provider (without https://)"
  type        = string
}

# ============================================================
# HARBOR CONFIGURATION
# ============================================================

variable "harbor_namespace" {
  description = "Kubernetes namespace for Harbor deployment"
  type        = string
  default     = "harbor"
}

variable "harbor_chart_version" {
  description = "Harbor Helm chart version"
  type        = string
  default     = "1.14.0"
}

variable "harbor_external_url" {
  description = "External URL for Harbor (e.g., https://registry.weaura.ai)"
  type        = string
}

variable "harbor_admin_password" {
  description = "Harbor admin password (only used if not using Secrets Manager)"
  type        = string
  default     = ""
  sensitive   = true
}

# ============================================================
# STORAGE CONFIGURATION
# ============================================================

variable "create_s3_bucket" {
  description = "Whether to create the S3 bucket for Harbor storage"
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "S3 bucket name for Harbor image storage (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "s3_kms_key_arn" {
  description = "KMS key ARN for S3 bucket encryption (uses AES256 if empty)"
  type        = string
  default     = ""
}

variable "s3_lifecycle_enabled" {
  description = "Enable lifecycle rules for S3 bucket"
  type        = bool
  default     = true
}

variable "s3_lifecycle_transition_ia_days" {
  description = "Days before transitioning objects to IA storage class"
  type        = number
  default     = 90
}

variable "s3_lifecycle_transition_glacier_days" {
  description = "Days before transitioning objects to Glacier storage class"
  type        = number
  default     = 180
}

variable "s3_lifecycle_expiration_days" {
  description = "Days before expiring objects (0 to disable)"
  type        = number
  default     = 0
}

# ============================================================
# DATABASE CONFIGURATION (Bitnami PostgreSQL)
# ============================================================

variable "database_type" {
  description = "Database type: internal (Bitnami PostgreSQL in-cluster)"
  type        = string
  default     = "internal"

  validation {
    condition     = var.database_type == "internal"
    error_message = "Only 'internal' database type is supported (Bitnami PostgreSQL)."
  }
}

variable "database_storage_size" {
  description = "Storage size for internal PostgreSQL database"
  type        = string
  default     = "10Gi"
}

variable "database_storage_class" {
  description = "Storage class for internal PostgreSQL database"
  type        = string
  default     = "gp3"
}

# ============================================================
# CACHE CONFIGURATION (Bitnami Redis)
# ============================================================

variable "redis_type" {
  description = "Redis type: internal (Bitnami Redis in-cluster)"
  type        = string
  default     = "internal"

  validation {
    condition     = var.redis_type == "internal"
    error_message = "Only 'internal' Redis type is supported (Bitnami Redis)."
  }
}

variable "redis_storage_size" {
  description = "Storage size for internal Redis"
  type        = string
  default     = "1Gi"
}

variable "redis_storage_class" {
  description = "Storage class for internal Redis"
  type        = string
  default     = "gp3"
}

# ============================================================
# TRIVY SCANNER CONFIGURATION
# ============================================================

variable "enable_trivy" {
  description = "Enable Trivy vulnerability scanner"
  type        = bool
  default     = true
}

# ============================================================
# INGRESS CONFIGURATION
# ============================================================

variable "ingress_class" {
  description = "Ingress class name (e.g., alb, nginx)"
  type        = string
  default     = "alb"
}

variable "ingress_annotations" {
  description = "Additional annotations for the Ingress resource"
  type        = map(string)
  default     = {}
}

variable "alb_certificate_arn" {
  description = "ACM certificate ARN for ALB HTTPS listener"
  type        = string
  default     = ""
}

variable "alb_scheme" {
  description = "ALB scheme: internet-facing or internal"
  type        = string
  default     = "internet-facing"

  validation {
    condition     = contains(["internet-facing", "internal"], var.alb_scheme)
    error_message = "ALB scheme must be 'internet-facing' or 'internal'."
  }
}

variable "alb_target_type" {
  description = "ALB target type: ip or instance"
  type        = string
  default     = "ip"

  validation {
    condition     = contains(["ip", "instance"], var.alb_target_type)
    error_message = "ALB target type must be 'ip' or 'instance'."
  }
}

variable "alb_ssl_policy" {
  description = "SSL policy for ALB HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "alb_subnets" {
  description = "Subnet IDs for ALB (comma-separated string)"
  type        = string
  default     = ""
}

# ============================================================
# SECRETS MANAGER CONFIGURATION
# ============================================================

variable "create_secrets" {
  description = "Whether to create secrets in AWS Secrets Manager"
  type        = bool
  default     = true
}

variable "secrets_manager_prefix" {
  description = "Prefix for secrets in AWS Secrets Manager"
  type        = string
  default     = ""
}

variable "external_secrets_cluster_store_name" {
  description = "Name of the ClusterSecretStore for External Secrets Operator"
  type        = string
  default     = "aws-secrets-manager"
}

# ============================================================
# RESOURCE QUOTAS AND LIMITS
# ============================================================

variable "enable_resource_quotas" {
  description = "Whether to create ResourceQuotas for the namespace"
  type        = bool
  default     = true
}

variable "enable_limit_ranges" {
  description = "Whether to create LimitRanges for the namespace"
  type        = bool
  default     = true
}

variable "enable_network_policies" {
  description = "Whether to create NetworkPolicies for the namespace"
  type        = bool
  default     = true
}

variable "resource_quota" {
  description = "Resource quota configuration for Harbor namespace"
  type = object({
    requests_cpu    = string
    requests_memory = string
    limits_cpu      = string
    limits_memory   = string
    pvcs            = string
    services        = string
    secrets         = string
    configmaps      = string
  })
  default = {
    requests_cpu    = "8"
    requests_memory = "16Gi"
    limits_cpu      = "16"
    limits_memory   = "32Gi"
    pvcs            = "20"
    services        = "20"
    secrets         = "50"
    configmaps      = "50"
  }
}

variable "limit_range" {
  description = "Limit range configuration for Harbor namespace"
  type = object({
    default_cpu            = string
    default_memory         = string
    default_request_cpu    = string
    default_request_memory = string
    min_cpu                = string
    min_memory             = string
    max_cpu                = string
    max_memory             = string
  })
  default = {
    default_cpu            = "500m"
    default_memory         = "512Mi"
    default_request_cpu    = "100m"
    default_request_memory = "128Mi"
    min_cpu                = "10m"
    min_memory             = "16Mi"
    max_cpu                = "4"
    max_memory             = "8Gi"
  }
}

# ============================================================
# NODE SCHEDULING
# ============================================================

variable "node_selector" {
  description = "Node selector for Harbor pods"
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Tolerations for Harbor pods"
  type = list(object({
    key      = string
    operator = string
    value    = optional(string)
    effect   = string
  }))
  default = []
}

# ============================================================
# HARBOR COMPONENT RESOURCES
# ============================================================

variable "core_resources" {
  description = "Resource requests and limits for Harbor Core"
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
      cpu    = "1"
      memory = "1Gi"
    }
  }
}

variable "jobservice_resources" {
  description = "Resource requests and limits for Harbor JobService"
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
      cpu    = "1"
      memory = "1Gi"
    }
  }
}

variable "registry_resources" {
  description = "Resource requests and limits for Harbor Registry"
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
      cpu    = "2"
      memory = "2Gi"
    }
  }
}

variable "trivy_resources" {
  description = "Resource requests and limits for Trivy scanner"
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
      cpu    = "2"
      memory = "2Gi"
    }
  }
}

variable "portal_resources" {
  description = "Resource requests and limits for Harbor Portal"
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
      cpu    = "50m"
      memory = "64Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "256Mi"
    }
  }
}

# ============================================================
# HARBOR REPLICAS
# ============================================================

variable "core_replicas" {
  description = "Number of replicas for Harbor Core"
  type        = number
  default     = 2
}

variable "jobservice_replicas" {
  description = "Number of replicas for Harbor JobService"
  type        = number
  default     = 1
}

variable "registry_replicas" {
  description = "Number of replicas for Harbor Registry"
  type        = number
  default     = 2
}

variable "portal_replicas" {
  description = "Number of replicas for Harbor Portal"
  type        = number
  default     = 1
}

variable "trivy_replicas" {
  description = "Number of replicas for Trivy scanner"
  type        = number
  default     = 1
}
