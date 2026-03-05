# ============================================================
# Greenfield Deployment: VPC → EKS → Monitoring Stack
# ============================================================
# This example deploys a complete infrastructure from scratch:
#   1. VPC with public/private subnets and NAT gateway
#   2. EKS cluster (standard MNG or Auto Mode)
#   3. WeAura monitoring stack (Grafana, Loki, Mimir, Tempo, Prometheus)
#
# Usage:
#   cp terraform.tfvars.example terraform.tfvars
#   # Edit terraform.tfvars with your values
#   terraform init
#   terraform plan
#   terraform apply
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
      version = ">= 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11.0"
    }
  }
}

# --------------------------------
# AWS Provider
# --------------------------------

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

# --------------------------------
# Kubernetes & Helm Providers
# --------------------------------
# Uses exec-based auth so providers work even before the cluster exists
# (token is fetched at apply-time, not plan-time).

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# ============================================================
# 1. VPC
# ============================================================

module "vpc" {
  source = "../../../../vpc"

  name               = var.project_name
  cluster_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tags               = var.tags
}

# ============================================================
# 2. EKS Cluster
# ============================================================

module "eks" {
  source = "../../../../eks"

  cluster_name              = var.project_name
  kubernetes_version        = "1.35"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  enable_auto_mode          = var.enable_auto_mode
  enable_pod_identity_agent = true
  endpoint_public_access    = true

  node_group_config = var.enable_auto_mode ? {
    desired_size   = 0
    max_size       = 0
    min_size       = 0
    instance_types = ["t3.xlarge"]
    disk_size      = 50
    } : {
    desired_size   = 3
    max_size       = 5
    min_size       = 1
    instance_types = ["t3.xlarge"]
    disk_size      = 50
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Default StorageClass — fresh EKS MNG clusters include gp2 but it is NOT
# marked as default. PVCs that omit storageClassName will fail to bind.
# Auto Mode handles StorageClasses automatically, so this is MNG-only.
# -----------------------------------------------------------------------------
resource "kubernetes_annotations" "default_storage_class" {
  count = var.enable_auto_mode ? 0 : 1

  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "true"
  }
  force      = true
  depends_on = [module.eks]
}

# ============================================================
# 3. Monitoring Stack
# ============================================================

module "monitoring" {
  source = "../../"

  cluster_name     = module.eks.cluster_name
  region           = var.region
  namespace        = "monitoring"
  create_namespace = true
  chart_version    = "0.15.0"

  # Harbor registry
  harbor_url      = var.harbor_url
  harbor_username = var.harbor_username
  harbor_password = var.harbor_password

  # IAM mode auto-selects based on EKS Auto Mode
  cloud_provider = "aws"
  iam_mode       = var.enable_auto_mode ? "pod_identity" : "irsa"
  sizing_preset  = var.sizing_preset

  aws_config = {
    s3_bucket_prefix = var.project_name
  }

  grafana    = { enabled = true, admin_password = var.grafana_admin_password }
  loki       = { enabled = true, retention = "168h" }
  mimir      = { enabled = true, retention = "168h" }
  tempo      = { enabled = true, retention = "168h" }
  prometheus = { enabled = true }
  pyroscope  = { enabled = false }

  tags = var.tags

  depends_on = [module.eks]
}
