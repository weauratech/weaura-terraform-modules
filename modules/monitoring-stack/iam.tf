# ============================================================
# IAM Resources for Harbor Chart Pull and S3 Access
# ============================================================


# --------------------------------
# IAM Role for IRSA (if enabled)
# --------------------------------

resource "aws_iam_role" "monitoring" {
  count = var.aws_config.use_irsa && var.cloud_provider == "aws" ? 1 : 0

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
  count = var.aws_config.use_irsa && var.cloud_provider == "aws" ? 1 : 0

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
  count = var.aws_config.use_irsa && var.cloud_provider == "aws" ? 1 : 0

  role       = aws_iam_role.monitoring[0].name
  policy_arn = aws_iam_policy.s3_access[0].arn
}
