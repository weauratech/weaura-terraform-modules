# ============================================================
# AWS IAM - IRSA for Harbor Container Registry
# ============================================================
# IAM Role for Service Accounts (IRSA) for Harbor Registry.
# Provides access to S3 bucket for container image storage.
# Only created when cloud_provider = "aws"
# ============================================================

# -----------------------------
# Assume Role Policy
# -----------------------------
data "aws_iam_policy_document" "harbor_assume_role" {
  count = local.is_aws ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Allow multiple Harbor service accounts to assume this role
    condition {
      test     = "StringLike"
      variable = "${local.oidc_provider_url}:sub"
      values = [
        "system:serviceaccount:${local.namespace}:harbor-registry",
        "system:serviceaccount:${local.namespace}:harbor-core",
        "system:serviceaccount:${local.namespace}:harbor-jobservice",
      ]
    }
  }
}

# -----------------------------
# IAM Role
# -----------------------------
resource "aws_iam_role" "harbor" {
  count = local.is_aws ? 1 : 0

  name               = local.irsa_role_name
  assume_role_policy = data.aws_iam_policy_document.harbor_assume_role[0].json

  tags = merge(local.default_tags, {
    Name      = local.irsa_role_name
    Component = "harbor"
    Namespace = local.namespace
  })
}

# -----------------------------
# S3 Policy Document
# -----------------------------
data "aws_iam_policy_document" "harbor_s3" {
  count = local.is_aws && var.create_s3_bucket ? 1 : 0

  # List bucket
  statement {
    sid    = "HarborListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [aws_s3_bucket.harbor[0].arn]
  }

  # Object operations
  statement {
    sid    = "HarborObjectOperations"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
    ]
    resources = ["${aws_s3_bucket.harbor[0].arn}/*"]
  }

  # KMS operations (if using KMS encryption)
  dynamic "statement" {
    for_each = var.s3_kms_key_arn != "" ? [1] : []
    content {
      sid    = "HarborKMSOperations"
      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
      resources = [var.s3_kms_key_arn]
    }
  }
}

# -----------------------------
# IAM Policy
# -----------------------------
resource "aws_iam_policy" "harbor_s3" {
  count = local.is_aws && var.create_s3_bucket ? 1 : 0

  name        = "${local.irsa_role_name}-s3-policy"
  description = "IAM policy for Harbor to access S3 bucket for image storage"
  policy      = data.aws_iam_policy_document.harbor_s3[0].json

  tags = merge(local.default_tags, {
    Name      = "${local.irsa_role_name}-s3-policy"
    Component = "harbor"
  })
}

# -----------------------------
# Policy Attachment
# -----------------------------
resource "aws_iam_role_policy_attachment" "harbor_s3" {
  count = local.is_aws && var.create_s3_bucket ? 1 : 0

  role       = aws_iam_role.harbor[0].name
  policy_arn = aws_iam_policy.harbor_s3[0].arn
}
