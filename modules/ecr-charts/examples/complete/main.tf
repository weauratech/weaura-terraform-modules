# ============================================================
# Complete Example - ECR Charts Module
# ============================================================
# This example demonstrates deploying ECR repositories for
# WeAura vendorized Helm charts with cross-account access.
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# --------------------------------
# Provider Configuration
# --------------------------------

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "WeAura"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# --------------------------------
# ECR Charts Module
# --------------------------------

module "ecr_charts" {
  source = "../../"

  charts = {
    weaura-monitoring = {
      name        = "weaura-monitoring"
      description = "WeAura monitoring stack umbrella chart (Grafana, Loki, Mimir, Tempo, Prometheus, Pyroscope)"
    }
  }

  repository_prefix = "weaura-vendorized/charts"

  # Security scanning
  scan_on_push = true

  # Encryption
  encryption_type = "AES256"

  # Lifecycle: Keep last 20 versions
  lifecycle_policy_rules = {
    max_image_count = 20
  }

  # Cross-account access: Allow any AWS account to pull (IAM-based)
  # Change to specific account IDs for stricter access control
  cross_account_pull_principals = ["*"]

  tags = {
    Repository = "weaura-terraform-modules"
    Module     = "ecr-charts"
  }
}

# --------------------------------
# Outputs
# --------------------------------

output "repository_urls" {
  description = "ECR repository URLs for each chart"
  value       = module.ecr_charts.repository_urls
}

output "oci_urls" {
  description = "Full OCI URLs for Helm chart pull"
  value       = module.ecr_charts.oci_urls
}

output "registry_id" {
  description = "ECR registry ID (AWS account)"
  value       = module.ecr_charts.registry_id
}

output "pull_commands" {
  description = "Example Helm pull commands"
  value       = module.ecr_charts.pull_commands
}
