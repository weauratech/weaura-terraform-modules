# ============================================================
# IAM Resources for ECR Cross-Account Pull
# ============================================================

# --------------------------------
# IAM Policy for ECR Pull
# --------------------------------

resource "aws_iam_policy" "ecr_pull" {
  name        = "${var.cluster_name}-monitoring-ecr-pull"
  description = "Allow pulling Helm charts from WeAura ECR registry (cross-account)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRGetAuthorizationToken"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRPullCharts"
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories"
        ]
        Resource = [
          "arn:aws:ecr:${var.ecr_region}:${var.ecr_account_id}:repository/weaura-vendorized/charts/*"
        ]
      }
    ]
  })

  tags = local.common_tags
}

# --------------------------------
# IAM Role for IRSA (if enabled)
# --------------------------------

resource "aws_iam_role" "monitoring" {
  count = var.aws_config.use_irsa && var.cloud_provider == "aws" ? 1 : 0

  name        = "${var.cluster_name}-monitoring"
  description = "IAM role for WeAura monitoring stack with S3 and ECR access"

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
# Attach ECR Pull Policy to IRSA Role
# --------------------------------

resource "aws_iam_role_policy_attachment" "ecr_pull" {
  count = var.aws_config.use_irsa && var.cloud_provider == "aws" ? 1 : 0

  role       = aws_iam_role.monitoring[0].name
  policy_arn = aws_iam_policy.ecr_pull.arn
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
