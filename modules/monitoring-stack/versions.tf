# ============================================================
# Module Provider Requirements
# ============================================================
# Required providers for WeAura Monitoring Stack deployment.
# Deploys umbrella Helm chart from ECR OCI registry.
# Provider configuration is done at the root level.
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # --------------------------------
    # Cloud Providers
    # --------------------------------

    # AWS Provider - IAM, EKS
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

    # --------------------------------
    # Kubernetes & Helm
    # --------------------------------

    # Kubernetes Provider - Namespaces, ServiceAccounts
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }

    # Helm Provider - Chart installations
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}
