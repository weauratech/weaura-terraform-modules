# ============================================================
# Module Provider Requirements
# ============================================================
# Required providers for AWS support.
# Provider configuration is done at the root level.
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # --------------------------------
    # Cloud Providers
    # --------------------------------

    # AWS Provider - Secrets Manager, IAM, S3
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
    # Grafana
    # --------------------------------

    # Grafana Provider - Dashboards, Alerting, Datasources
    grafana = {
      source  = "grafana/grafana"
      version = "~> 2.15"
    }

    # --------------------------------
    # Utilities
    # --------------------------------

    # Time Provider - Delays and waits
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10"
    }

    # Null Provider - Local execution resources
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }

    # Random Provider - Random string generation
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
