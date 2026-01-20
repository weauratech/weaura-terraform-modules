# ============================================================
# Helm Release - Harbor Container Registry
# ============================================================
# Deploys Harbor container registry using the official Helm chart.
# Configured for AWS EKS with ALB ingress, S3 storage,
# internal PostgreSQL and Redis.
# ============================================================

# -----------------------------
# Random password for database (internal)
# -----------------------------
resource "random_password" "database" {
  length  = 16
  special = false
}

# -----------------------------
# Helm Release
# -----------------------------
resource "helm_release" "harbor" {
  name             = "harbor"
  namespace        = kubernetes_namespace.harbor.metadata[0].name
  repository       = local.helm_repository
  chart            = "harbor"
  version          = var.harbor_chart_version
  create_namespace = false
  wait             = true
  wait_for_jobs    = true
  timeout          = 900
  atomic           = true
  cleanup_on_fail  = true

  values = [
    templatefile("${path.module}/templates/harbor-values.yaml.tpl", {
      # Harbor configuration
      external_url  = var.harbor_external_url
      hostname      = local.harbor_hostname
      ingress_class = var.ingress_class

      # Ingress annotations
      ingress_annotations = local.ingress_annotations

      # AWS configuration
      aws_region     = var.aws_region
      s3_bucket_name = local.is_aws && var.create_s3_bucket ? aws_s3_bucket.harbor[0].id : var.s3_bucket_name
      s3_encrypted   = var.s3_kms_key_arn != "" ? "true" : "false"
      s3_kms_key_id  = var.s3_kms_key_arn

      # Storage configuration
      storage_class = var.database_storage_class

      # Database configuration
      database_password      = random_password.database.result
      database_storage_size  = var.database_storage_size
      database_storage_class = var.database_storage_class

      # Redis configuration
      redis_storage_size  = var.redis_storage_size
      redis_storage_class = var.redis_storage_class

      # Trivy configuration
      enable_trivy = var.enable_trivy

      # Harbor version (for image tags)
      harbor_version = "v${var.harbor_chart_version}"

      # Admin password
      admin_password = local.harbor_admin_password_value

      # Secret key for encryption
      harbor_secret_key = local.harbor_secret_key_value

      # Service account for IRSA
      registry_service_account = local.is_aws ? kubernetes_service_account.harbor_registry[0].metadata[0].name : "default"

      # Replicas
      core_replicas       = var.core_replicas
      jobservice_replicas = var.jobservice_replicas
      registry_replicas   = var.registry_replicas
      portal_replicas     = var.portal_replicas
      trivy_replicas      = var.trivy_replicas

      # Core resources
      core_resources_requests_cpu    = var.core_resources.requests.cpu
      core_resources_requests_memory = var.core_resources.requests.memory
      core_resources_limits_cpu      = var.core_resources.limits.cpu
      core_resources_limits_memory   = var.core_resources.limits.memory

      # JobService resources
      jobservice_resources_requests_cpu    = var.jobservice_resources.requests.cpu
      jobservice_resources_requests_memory = var.jobservice_resources.requests.memory
      jobservice_resources_limits_cpu      = var.jobservice_resources.limits.cpu
      jobservice_resources_limits_memory   = var.jobservice_resources.limits.memory

      # Registry resources
      registry_resources_requests_cpu    = var.registry_resources.requests.cpu
      registry_resources_requests_memory = var.registry_resources.requests.memory
      registry_resources_limits_cpu      = var.registry_resources.limits.cpu
      registry_resources_limits_memory   = var.registry_resources.limits.memory

      # Portal resources
      portal_resources_requests_cpu    = var.portal_resources.requests.cpu
      portal_resources_requests_memory = var.portal_resources.requests.memory
      portal_resources_limits_cpu      = var.portal_resources.limits.cpu
      portal_resources_limits_memory   = var.portal_resources.limits.memory

      # Trivy resources
      trivy_resources_requests_cpu    = var.trivy_resources.requests.cpu
      trivy_resources_requests_memory = var.trivy_resources.requests.memory
      trivy_resources_limits_cpu      = var.trivy_resources.limits.cpu
      trivy_resources_limits_memory   = var.trivy_resources.limits.memory

      # Node scheduling
      node_selector = var.node_selector
      tolerations   = var.tolerations
    })
  ]

  depends_on = [
    kubernetes_namespace.harbor,
    kubernetes_resource_quota.harbor,
    kubernetes_limit_range.harbor,
    kubernetes_service_account.harbor_registry,
    aws_s3_bucket.harbor,
    aws_iam_role_policy_attachment.harbor_s3,
    kubectl_manifest.harbor_admin_external_secret,
    kubectl_manifest.harbor_secret_key_external_secret,
  ]
}
