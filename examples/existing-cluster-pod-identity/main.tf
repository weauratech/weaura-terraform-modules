# ============================================================
# Existing Cluster (Pod Identity) - WeAura Monitoring Stack
# ============================================================
# Full-featured deployment on an existing EKS cluster using
# EKS Pod Identity instead of IRSA. All monitoring components
# enabled with enterprise features.
# ============================================================

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.79.0"
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
  region = var.region

  default_tags {
    tags = {
      Project     = "WeAura Monitoring"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.region]
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.region]
    }
  }
}

# --------------------------------
# Monitoring Stack Module
# --------------------------------

module "monitoring" {
  source = "github.com/weauratech/weaura-terraform-modules//modules/vendorize/monitoring?ref=v2.0.0"

  cluster_name     = var.cluster_name
  region           = var.region
  namespace        = var.namespace
  create_namespace = true

  # Harbor registry credentials
  harbor_url      = var.harbor_url
  harbor_username = var.harbor_username
  harbor_password = var.harbor_password

  # Pod Identity mode (no OIDC provider required)
  cloud_provider = "aws"
  iam_mode       = "pod_identity"
  sizing_preset  = var.sizing_preset

  # AWS configuration
  aws_config = {
    s3_bucket_prefix = var.s3_bucket_prefix
  }

  # Enterprise features
  pdb_enabled                 = true
  alert_rules_enabled         = true
  service_monitor_auto_enable = true

  # Grafana
  grafana = {
    enabled             = true
    admin_password      = var.grafana_admin_password
    ingress_enabled     = var.grafana_ingress_enabled
    ingress_host        = var.grafana_ingress_host
    storage_size        = "20Gi"
    persistence_enabled = true
  }

  # Loki (Logs)
  loki = {
    enabled      = true
    storage_size = var.loki_storage_size
    retention    = var.loki_retention
  }

  # Mimir (Long-term Metrics)
  mimir = {
    enabled      = true
    storage_size = var.mimir_storage_size
    retention    = var.mimir_retention
  }

  # Tempo (Traces)
  tempo = {
    enabled      = true
    storage_size = var.tempo_storage_size
    retention    = var.tempo_retention
  }

  # Prometheus (Short-term Metrics)
  prometheus = {
    enabled      = true
    storage_size = var.prometheus_storage_size
    retention    = var.prometheus_retention
  }

  # Pyroscope (Profiling)
  pyroscope = {
    enabled      = true
    storage_size = var.pyroscope_storage_size
  }

  helm_values = var.additional_helm_values

  tags = merge(var.tags, {
    Environment = var.environment
  })
}
