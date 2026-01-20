# ============================================================
# Outputs - Harbor Container Registry Module
# ============================================================
# Module outputs for integration with other systems.
# ============================================================

# ============================================================
# HARBOR OUTPUTS
# ============================================================

output "harbor_url" {
  description = "Harbor external URL"
  value       = var.harbor_external_url
}

output "harbor_hostname" {
  description = "Harbor hostname (without protocol)"
  value       = local.harbor_hostname
}

output "harbor_namespace" {
  description = "Kubernetes namespace where Harbor is deployed"
  value       = kubernetes_namespace.harbor.metadata[0].name
}

output "harbor_helm_release_name" {
  description = "Harbor Helm release name"
  value       = helm_release.harbor.name
}

output "harbor_helm_release_version" {
  description = "Harbor Helm chart version deployed"
  value       = helm_release.harbor.version
}

output "harbor_helm_release_status" {
  description = "Harbor Helm release status"
  value       = helm_release.harbor.status
}

# ============================================================
# AWS S3 OUTPUTS
# ============================================================

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Harbor image storage"
  value       = local.is_aws && var.create_s3_bucket ? aws_s3_bucket.harbor[0].id : null
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Harbor image storage"
  value       = local.is_aws && var.create_s3_bucket ? aws_s3_bucket.harbor[0].arn : null
}

output "s3_bucket_region" {
  description = "Region of the S3 bucket"
  value       = local.is_aws && var.create_s3_bucket ? aws_s3_bucket.harbor[0].region : null
}

# ============================================================
# AWS IAM OUTPUTS
# ============================================================

output "iam_role_arn" {
  description = "ARN of the IAM role for Harbor IRSA"
  value       = local.is_aws ? aws_iam_role.harbor[0].arn : null
}

output "iam_role_name" {
  description = "Name of the IAM role for Harbor IRSA"
  value       = local.is_aws ? aws_iam_role.harbor[0].name : null
}

# ============================================================
# AWS SECRETS MANAGER OUTPUTS
# ============================================================

output "secrets_manager_admin_password_arn" {
  description = "ARN of the Secrets Manager secret for Harbor admin password"
  value       = local.is_aws && var.create_secrets ? aws_secretsmanager_secret.harbor_admin[0].arn : null
}

output "secrets_manager_secret_key_arn" {
  description = "ARN of the Secrets Manager secret for Harbor encryption key"
  value       = local.is_aws && var.create_secrets ? aws_secretsmanager_secret.harbor_secret_key[0].arn : null
}

# ============================================================
# KUBERNETES SERVICE ACCOUNT OUTPUTS
# ============================================================

output "service_account_name" {
  description = "Name of the Kubernetes service account with IRSA annotation"
  value       = local.is_aws ? kubernetes_service_account.harbor_registry[0].metadata[0].name : null
}

# ============================================================
# MODULE SUMMARY
# ============================================================

output "module_summary" {
  description = "Summary of module deployment"
  value = {
    cloud_provider = var.cloud_provider
    environment    = var.environment
    project        = var.project

    harbor = {
      url       = var.harbor_external_url
      hostname  = local.harbor_hostname
      namespace = kubernetes_namespace.harbor.metadata[0].name
      version   = var.harbor_chart_version
    }

    storage = {
      type        = "s3"
      bucket_name = local.is_aws && var.create_s3_bucket ? aws_s3_bucket.harbor[0].id : var.s3_bucket_name
      encrypted   = var.s3_kms_key_arn != ""
    }

    database = {
      type         = var.database_type
      storage_size = var.database_storage_size
    }

    redis = {
      type         = var.redis_type
      storage_size = var.redis_storage_size
    }

    components = {
      trivy_enabled = var.enable_trivy
    }

    replicas = {
      core       = var.core_replicas
      registry   = var.registry_replicas
      jobservice = var.jobservice_replicas
      portal     = var.portal_replicas
      trivy      = var.enable_trivy ? var.trivy_replicas : 0
    }

    features = {
      resource_quotas  = var.enable_resource_quotas
      limit_ranges     = var.enable_limit_ranges
      network_policies = var.enable_network_policies
    }
  }
}

# ============================================================
# DOCKER LOGIN COMMAND
# ============================================================

output "docker_login_command" {
  description = "Docker login command for Harbor registry"
  value       = "docker login ${local.harbor_hostname}"
}

# ============================================================
# INGRESS INFORMATION
# ============================================================

output "ingress_annotations" {
  description = "Ingress annotations applied to Harbor"
  value       = local.ingress_annotations
}
