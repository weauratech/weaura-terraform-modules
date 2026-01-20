# ============================================================
# Local Values - Harbor Container Registry Module
# ============================================================
# Centralized local values for Harbor configuration.
# ============================================================

locals {
  # ============================================================
  # CLOUD PROVIDER FLAGS
  # ============================================================
  is_aws = var.cloud_provider == "aws"

  # ============================================================
  # NAMING
  # ============================================================
  name_prefix = var.name_prefix != "" ? var.name_prefix : var.project
  full_name   = "${local.name_prefix}-${var.environment}"

  # ============================================================
  # NAMESPACE
  # ============================================================
  namespace = var.harbor_namespace

  # ============================================================
  # S3 BUCKET CONFIGURATION
  # ============================================================
  s3_bucket_name = var.s3_bucket_name != "" ? var.s3_bucket_name : "${local.full_name}-harbor-registry"

  # ============================================================
  # SECRETS PATHS
  # ============================================================
  secrets_prefix = var.secrets_manager_prefix != "" ? var.secrets_manager_prefix : "${local.full_name}/harbor"

  secrets_paths = {
    admin_password = "${local.secrets_prefix}/admin-password"
    secret_key     = "${local.secrets_prefix}/secret-key"
  }

  # ============================================================
  # OIDC PROVIDER (AWS)
  # ============================================================
  oidc_provider_arn = local.is_aws ? var.eks_oidc_provider_arn : ""
  oidc_provider_url = local.is_aws ? replace(var.eks_oidc_provider_url, "https://", "") : ""

  # ============================================================
  # IRSA CONFIGURATION
  # ============================================================
  irsa_role_name = "${local.full_name}-harbor"

  # Service accounts that need S3 access
  harbor_service_accounts = [
    "harbor-registry",
    "harbor-core",
    "harbor-jobservice",
  ]

  # ============================================================
  # HARBOR EXTERNAL URL
  # ============================================================
  harbor_hostname = replace(replace(var.harbor_external_url, "https://", ""), "http://", "")

  # ============================================================
  # INGRESS ANNOTATIONS (ALB)
  # ============================================================
  default_alb_annotations = {
    "kubernetes.io/ingress.class"                        = "alb"
    "alb.ingress.kubernetes.io/scheme"                   = var.alb_scheme
    "alb.ingress.kubernetes.io/target-type"              = var.alb_target_type
    "alb.ingress.kubernetes.io/listen-ports"             = "[{\"HTTPS\":443}]"
    "alb.ingress.kubernetes.io/ssl-policy"               = var.alb_ssl_policy
    "alb.ingress.kubernetes.io/backend-protocol"         = "HTTP"
    "alb.ingress.kubernetes.io/healthcheck-path"         = "/api/v2.0/health"
    "alb.ingress.kubernetes.io/healthcheck-port"         = "traffic-port"
    "alb.ingress.kubernetes.io/healthcheck-protocol"     = "HTTP"
    "alb.ingress.kubernetes.io/success-codes"            = "200"
    "alb.ingress.kubernetes.io/group.name"               = "${local.full_name}-harbor"
    "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=3600"
  }

  # Add certificate ARN if provided
  alb_annotations_with_cert = var.alb_certificate_arn != "" ? merge(local.default_alb_annotations, {
    "alb.ingress.kubernetes.io/certificate-arn" = var.alb_certificate_arn
  }) : local.default_alb_annotations

  # Add subnets if provided
  alb_annotations_with_subnets = var.alb_subnets != "" ? merge(local.alb_annotations_with_cert, {
    "alb.ingress.kubernetes.io/subnets" = var.alb_subnets
  }) : local.alb_annotations_with_cert

  # Merge with user-provided annotations
  ingress_annotations = merge(local.alb_annotations_with_subnets, var.ingress_annotations)

  # ============================================================
  # COMMON LABELS (Kubernetes)
  # ============================================================
  common_labels = merge(var.labels, {
    "app.kubernetes.io/part-of"    = "harbor-registry"
    "app.kubernetes.io/managed-by" = "terraform"
    "environment"                  = var.environment
    "cloud-provider"               = var.cloud_provider
  })

  # ============================================================
  # CLOUD TAGS
  # ============================================================
  default_tags = merge(var.tags, {
    Project       = var.project
    Environment   = var.environment
    ManagedBy     = "terraform"
    CloudProvider = var.cloud_provider
    Component     = "harbor"
  })

  # ============================================================
  # HELM CHART CONFIGURATION
  # ============================================================
  helm_repository = "https://helm.goharbor.io"
}
