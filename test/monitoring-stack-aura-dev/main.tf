terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
  }
}

# ============================================================
# AWS Provider Configuration
# ============================================================

provider "aws" {
  region  = "us-east-2"
  profile = "weaura"
}

# ============================================================
# Kubernetes & Helm Provider Configuration
# ============================================================

data "aws_eks_cluster" "target" {
  name = "aura-dev"
}

data "aws_eks_cluster_auth" "target" {
  name = "aura-dev"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.target.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.target.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.target.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.target.token
  }
}

# ============================================================
# Monitoring Stack Deployment (Local Module for Testing)
# ============================================================

module "monitoring_stack" {
  source = "../../modules/monitoring-stack"

  # Basic Configuration
  cluster_name     = "aura-dev"
  region           = "us-east-2"
  namespace        = "monitoring-test"
  create_namespace = true
  chart_version    = "0.1.2"

  # ECR Configuration (WeAura's vendorized charts)
  ecr_account_id = "950242546328"
  ecr_region     = "us-east-2"

  # Cloud Provider Configuration
  cloud_provider = "aws"
  aws_config = {
    s3_bucket_prefix = "weaura-monitoring-test"
    use_irsa         = true
  }

  # Grafana Configuration
  grafana = {
    enabled             = true
    admin_password      = "test-admin-password" # For testing only!
    ingress_enabled     = false
    ingress_host        = ""
    storage_size        = "2Gi" # Minimal for testing
    persistence_enabled = true
  }

  # Loki Configuration
  loki = {
    enabled      = true
    storage_size = "10Gi" # Minimal for testing
    retention    = "7d"   # Short retention for testing
  }

  # Mimir Configuration
  mimir = {
    enabled      = true
    storage_size = "20Gi" # Minimal for testing
    retention    = "15d"  # Short retention for testing
  }

  # Tempo Configuration
  tempo = {
    enabled      = true
    storage_size = "10Gi" # Minimal for testing
    retention    = "168h"  # 7 days in Go duration format (Tempo requirement)
  }

  # Prometheus Configuration
  prometheus = {
    enabled      = true
    storage_size = "10Gi" # Minimal for testing
    retention    = "168h"  # 7 days in Go duration format (Prometheus accepts both formats, but using consistent format)
  }

  # Pyroscope Configuration
  pyroscope = {
    enabled      = true
    storage_size = "5Gi" # Minimal for testing
  }

  # Additional Helm values - keep minimal for testing
  helm_values = {}

  # Tags
  tags = {
    Environment = "testing"
    Project     = "weaura-monitoring"
    ManagedBy   = "terraform"
    TestPhase   = "wave-5-phase-2"
    Purpose     = "integration-testing"
  }
}

# ============================================================
# Outputs
# ============================================================

output "namespace" {
  description = "Kubernetes namespace where monitoring stack is deployed"
  value       = module.monitoring_stack.namespace
}

output "grafana_service_name" {
  description = "Grafana Kubernetes service name"
  value       = try(module.monitoring_stack.grafana_service_name, "N/A")
}

output "s3_buckets" {
  description = "S3 buckets created for monitoring components"
  value       = try(module.monitoring_stack.s3_buckets, {})
}

output "iam_roles" {
  description = "IAM roles created for monitoring components"
  value       = try(module.monitoring_stack.iam_roles, {})
}

output "helm_release_name" {
  description = "Name of the Helm release"
  value       = try(module.monitoring_stack.helm_release_name, "N/A")
}

output "helm_release_status" {
  description = "Status of the Helm release"
  value       = try(module.monitoring_stack.helm_release_status, "N/A")
}

output "grafana_access" {
  description = "How to access Grafana"
  value = {
    username          = "admin"
    password          = "test-admin-password" # TESTING ONLY!
    port_forward      = "kubectl port-forward -n monitoring-test svc/weaura-monitoring-grafana 3000:80"
    grafana_url_local = "http://localhost:3000"
  }
  sensitive = true
}
