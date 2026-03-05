# ============================================================
# IAM Resources for Harbor Chart Pull and S3 Access
# ============================================================

locals {
  # Backwards-compatible mapping: if legacy use_irsa is set and iam_mode is default,
  # map use_irsa=true to iam_mode="irsa". New iam_mode takes precedence.
  effective_iam_mode = var.iam_mode != "" ? var.iam_mode : (
    try(var.aws_config.use_irsa, null) == true ? "irsa" : var.iam_mode
  )
}


# --------------------------------
# IAM Role for IRSA (if enabled)
# --------------------------------

resource "aws_iam_role" "monitoring" {
  count = local.effective_iam_mode == "irsa" && var.cloud_provider == "aws" ? 1 : 0

  name        = "${var.cluster_name}-monitoring"
  description = "IAM role for WeAura monitoring stack with S3 access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = local.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = [
            "system:serviceaccount:${var.namespace}:loki",
            "system:serviceaccount:${var.namespace}:mimir",
            "system:serviceaccount:${var.namespace}:tempo",
            "system:serviceaccount:${var.namespace}:pyroscope"
          ]
        }
      }
    }]
  })

  tags = local.common_tags
}


# --------------------------------
# IAM Policy for S3 Access (Loki, Mimir, Tempo, Pyroscope)
# --------------------------------

resource "aws_iam_policy" "s3_access" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name        = "${var.cluster_name}-monitoring-s3"
  description = "S3 access for monitoring stack storage"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ListBuckets"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${local.loki_s3_bucket}",
          "arn:aws:s3:::${local.mimir_s3_bucket}",
          "arn:aws:s3:::${local.tempo_s3_bucket}",
          "arn:aws:s3:::${local.pyroscope_s3_bucket}"
        ]
      },
      {
        Sid    = "S3ObjectOperations"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ]
        Resource = [
          "arn:aws:s3:::${local.loki_s3_bucket}/*",
          "arn:aws:s3:::${local.mimir_s3_bucket}/*",
          "arn:aws:s3:::${local.tempo_s3_bucket}/*",
          "arn:aws:s3:::${local.pyroscope_s3_bucket}/*"
        ]
      }
    ]
  })

  tags = local.common_tags
}

# --------------------------------
# Attach S3 Policy to IRSA Role
# --------------------------------

resource "aws_iam_role_policy_attachment" "s3_access" {
  count = local.effective_iam_mode == "irsa" && var.cloud_provider == "aws" ? 1 : 0

  role       = aws_iam_role.monitoring[0].name
  policy_arn = aws_iam_policy.s3_access[0].arn
}

# --------------------------------
# Pod Identity IAM Resources (EKS Auto Mode)
# --------------------------------

resource "aws_iam_role" "monitoring_pod_identity" {
  count = local.effective_iam_mode == "pod_identity" && var.cloud_provider == "aws" ? 1 : 0
  name  = "${var.cluster_name}-monitoring-pod-identity"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "pod_identity_s3" {
  count      = local.effective_iam_mode == "pod_identity" && var.cloud_provider == "aws" ? 1 : 0
  role       = aws_iam_role.monitoring_pod_identity[0].name
  policy_arn = aws_iam_policy.s3_access[0].arn
}

# Pod Identity Associations (one per component service account)
resource "aws_eks_pod_identity_association" "loki" {
  count           = local.effective_iam_mode == "pod_identity" && var.cloud_provider == "aws" && var.loki.enabled ? 1 : 0
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = "loki"
  role_arn        = aws_iam_role.monitoring_pod_identity[0].arn
}

resource "aws_eks_pod_identity_association" "mimir" {
  count           = local.effective_iam_mode == "pod_identity" && var.cloud_provider == "aws" && var.mimir.enabled ? 1 : 0
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = "mimir"
  role_arn        = aws_iam_role.monitoring_pod_identity[0].arn
}

resource "aws_eks_pod_identity_association" "tempo" {
  count           = local.effective_iam_mode == "pod_identity" && var.cloud_provider == "aws" && var.tempo.enabled ? 1 : 0
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = "tempo"
  role_arn        = aws_iam_role.monitoring_pod_identity[0].arn
}

resource "aws_eks_pod_identity_association" "pyroscope" {
  count           = local.effective_iam_mode == "pod_identity" && var.cloud_provider == "aws" && var.pyroscope.enabled ? 1 : 0
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = "pyroscope"
  role_arn        = aws_iam_role.monitoring_pod_identity[0].arn
}
