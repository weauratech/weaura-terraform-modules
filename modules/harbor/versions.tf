# ============================================================
# Module Provider Requirements
# ============================================================
# Required providers for Harbor Container Registry deployment.
# Supports AWS for production deployments.
# Provider configuration is done at the root level.
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # --------------------------------
    # Cloud Providers
    # --------------------------------

    # AWS Provider - Secrets Manager, IAM, S3, KMS
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    # --------------------------------
    # Kubernetes & Helm
    # --------------------------------

    # Kubernetes Provider - Namespaces, Secrets, ConfigMaps
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }

    # Helm Provider - Chart installations
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }

    # Kubectl Provider - CRDs and custom manifests
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }

    # --------------------------------
    # Utilities
    # --------------------------------

    # Random Provider - Random string generation
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
