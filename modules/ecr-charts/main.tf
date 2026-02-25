# ============================================================
# Amazon ECR Repositories for Helm Charts
# ============================================================
# Creates ECR repositories for storing Helm charts as OCI artifacts.
# Each chart gets its own repository with lifecycle policies and
# cross-account access controls.
# ============================================================

# --------------------------------
# ECR Repositories
# --------------------------------

resource "aws_ecr_repository" "charts" {
  for_each = var.charts

  name                 = "${var.repository_prefix}/${each.value.name}"
  image_tag_mutability = "IMMUTABLE" # Prevent overwriting tags

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key_arn : null
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.repository_prefix}/${each.value.name}"
      Chart       = each.value.name
      Description = each.value.description
      ManagedBy   = "Terraform"
      Module      = "ecr-charts"
    }
  )
}

# --------------------------------
# Lifecycle Policies
# --------------------------------

resource "aws_ecr_lifecycle_policy" "charts" {
  for_each   = aws_ecr_repository.charts
  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only last ${var.lifecycle_policy_rules.max_image_count} images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.lifecycle_policy_rules.max_image_count
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# --------------------------------
# Repository Policies (Cross-Account Access)
# --------------------------------

resource "aws_ecr_repository_policy" "charts" {
  for_each   = aws_ecr_repository.charts
  repository = each.value.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCrossAccountPull"
      Effect = "Allow"
      Principal = {
        AWS = var.cross_account_pull_principals
      }
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:DescribeImages",
        "ecr:DescribeRepositories"
      ]
    }]
  })
}
