# ============================================================
# Module Provider Requirements
# ============================================================
# Required providers for ECR Charts Repository deployment.
# Manages Amazon ECR repositories for Helm chart OCI storage.
# Provider configuration is done at the root level.
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # --------------------------------
    # Cloud Providers
    # --------------------------------

    # AWS Provider - ECR, IAM
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
