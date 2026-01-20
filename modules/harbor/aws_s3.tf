# ============================================================
# AWS S3 - Harbor Container Image Storage
# ============================================================
# S3 bucket for Harbor container image storage.
# Configured with encryption, versioning, and lifecycle rules.
# Only created when cloud_provider = "aws" and create_s3_bucket = true
# ============================================================

# -----------------------------
# S3 Bucket
# -----------------------------
resource "aws_s3_bucket" "harbor" {
  count = local.is_aws && var.create_s3_bucket ? 1 : 0

  bucket = local.s3_bucket_name

  tags = merge(local.default_tags, {
    Name      = local.s3_bucket_name
    Component = "harbor"
    Purpose   = "container-image-storage"
  })
}

# -----------------------------
# Versioning
# -----------------------------
resource "aws_s3_bucket_versioning" "harbor" {
  count = local.is_aws && var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.harbor[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# -----------------------------
# Encryption
# -----------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "harbor" {
  count = local.is_aws && var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.harbor[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.s3_kms_key_arn != "" ? "aws:kms" : "AES256"
      kms_master_key_id = var.s3_kms_key_arn != "" ? var.s3_kms_key_arn : null
    }
    bucket_key_enabled = true
  }
}

# -----------------------------
# Public Access Block
# -----------------------------
resource "aws_s3_bucket_public_access_block" "harbor" {
  count = local.is_aws && var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.harbor[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------
# Lifecycle Configuration
# -----------------------------
resource "aws_s3_bucket_lifecycle_configuration" "harbor" {
  count = local.is_aws && var.create_s3_bucket && var.s3_lifecycle_enabled ? 1 : 0

  bucket = aws_s3_bucket.harbor[0].id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    filter {}

    # Transition to Infrequent Access after configured days
    transition {
      days          = var.s3_lifecycle_transition_ia_days
      storage_class = "STANDARD_IA"
    }

    # Transition to Glacier after configured days
    dynamic "transition" {
      for_each = var.s3_lifecycle_transition_glacier_days > 0 ? [1] : []
      content {
        days          = var.s3_lifecycle_transition_glacier_days
        storage_class = "GLACIER"
      }
    }

    # Expire objects after configured days (if enabled)
    dynamic "expiration" {
      for_each = var.s3_lifecycle_expiration_days > 0 ? [1] : []
      content {
        days = var.s3_lifecycle_expiration_days
      }
    }

    # Clean up old versions after 30 days
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  # Rule to abort incomplete multipart uploads
  rule {
    id     = "abort-incomplete-multipart"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# -----------------------------
# Bucket Policy (optional - for additional security)
# -----------------------------
data "aws_iam_policy_document" "harbor_bucket_policy" {
  count = local.is_aws && var.create_s3_bucket ? 1 : 0

  # Deny non-HTTPS access
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.harbor[0].arn,
      "${aws_s3_bucket.harbor[0].arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "harbor" {
  count = local.is_aws && var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.harbor[0].id
  policy = data.aws_iam_policy_document.harbor_bucket_policy[0].json
}
