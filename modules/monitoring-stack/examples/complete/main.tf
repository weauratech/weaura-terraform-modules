# ============================================================
# Complete Example - WeAura Monitoring Stack
# ============================================================
# This example demonstrates a complete production deployment
# of the WeAura monitoring stack with all components enabled
# and custom configurations on AWS EKS.
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

# --------------------------------
# Provider Configuration
# --------------------------------

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "WeAura Monitoring"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

# Configure Kubernetes provider (auto-configured from EKS)
data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# --------------------------------
# Monitoring Stack Module
# --------------------------------

module "monitoring_stack" {
  source = "../../"

  # Required
  cloud_provider           = "aws"
  tenant_id                = var.tenant_id
  tenant_name              = var.tenant_name
  grafana_domain           = var.grafana_domain
  grafana_admin_password   = var.grafana_admin_password
  monitoring_chart_version = var.monitoring_chart_version

  # AWS Configuration
  aws_region            = var.aws_region
  eks_cluster_name      = var.eks_cluster_name
  eks_oidc_provider_arn = var.eks_oidc_provider_arn
  eks_oidc_provider_url = var.eks_oidc_provider_url

  # Environment
  environment = var.environment

  # Component toggles (all enabled for complete example)
  enable_grafana    = true
  enable_prometheus = true
  enable_loki       = true
  enable_mimir      = true
  enable_tempo      = true
  enable_pyroscope  = true

  # Harbor OCI auth
  harbor_username = var.harbor_username
  harbor_password = var.harbor_password

  # Tags
  tags = {
    Environment = var.environment
    Example     = "complete"
  }
}
