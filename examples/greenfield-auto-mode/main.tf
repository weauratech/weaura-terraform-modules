# ============================================================
# Greenfield (EKS Auto Mode) - Full Infrastructure
# ============================================================
# Provisions complete infrastructure from scratch:
#   1. VPC with public/private subnets and NAT Gateway
#   2. EKS cluster with Auto Mode (AWS manages nodes)
#   3. WeAura Monitoring Stack (all components)
#
# Auto Mode Differences:
#   - AWS fully manages node provisioning and scaling
#   - No manual node group configuration required
#   - StorageClass is handled automatically (no gp2 annotation)
#   - Cold start: first pods may take ~2-5 min while nodes spin up
#   - Uses Pod Identity (recommended for Auto Mode)
#
# Architecture:
#
#   ┌──────────────────────────────────────────────────────┐
#   │                        VPC                           │
#   │  ┌────────────┐  ┌────────────┐  ┌────────────┐     │
#   │  │ Public AZ-a│  │ Public AZ-b│  │ Public AZ-c│     │
#   │  └────────────┘  └────────────┘  └────────────┘     │
#   │  ┌────────────┐  ┌────────────┐  ┌────────────┐     │
#   │  │Private AZ-a│  │Private AZ-b│  │Private AZ-c│     │
#   │  └──────┬─────┘  └──────┬─────┘  └──────┬─────┘     │
#   │         │               │               │            │
#   │         └───────────────┼───────────────┘            │
#   │                         ▼                            │
#   │               ┌─────────────────┐                    │
#   │               │   EKS Cluster   │                    │
#   │               │   (Auto Mode)   │                    │
#   │               └────────┬────────┘                    │
#   │                        ▼                             │
#   │           ┌────────────────────────┐                 │
#   │           │   Monitoring Stack     │                 │
#   │           │ Grafana│Loki│Mimir│... │                 │
#   │           └────────────┬───────────┘                 │
#   │                        │                             │
#   └────────────────────────┼─────────────────────────────┘
#                            ▼
#                  ┌──────────────────┐
#                  │    S3 Buckets    │
#                  └──────────────────┘
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

  # Uncomment and configure for remote state:
  # backend "s3" {
  #   bucket         = "my-terraform-state"
  #   key            = "greenfield-auto-mode/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

# --------------------------------
# Provider Configuration
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

# Kubernetes/Helm providers use exec-based auth referencing module outputs.
# This ensures tokens are fetched at apply-time (not plan-time).

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
    }
  }
}

# ============================================================
# 1. VPC
# ============================================================

module "vpc" {
  source = "github.com/weauratech/weaura-terraform-modules//modules/vpc?ref=v2.0.0"

  name               = var.project_name
  cluster_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  tags = var.tags
}

# ============================================================
# 2. EKS Cluster (Auto Mode)
# ============================================================
# Auto Mode lets AWS manage node provisioning, scaling, and
# updates automatically. No manual node group sizing needed.
# Pod Identity is the recommended IAM approach for Auto Mode.

module "eks" {
  source = "github.com/weauratech/weaura-terraform-modules//modules/eks?ref=v2.0.0"

  cluster_name              = var.project_name
  kubernetes_version        = var.kubernetes_version
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  endpoint_public_access    = true
  enable_auto_mode          = true
  enable_pod_identity_agent = true

  # Auto Mode manages nodes automatically — set all sizes to 0
  # to prevent creation of a traditional Managed Node Group.
  node_group_config = {
    desired_size   = 0
    max_size       = 0
    min_size       = 0
    instance_types = []
    disk_size      = 0
  }

  tags = var.tags
}

# NOTE: No kubernetes_annotations for StorageClass needed.
# Auto Mode provisions and manages storage classes automatically.

# ============================================================
# 3. Monitoring Stack
# ============================================================

module "monitoring" {
  source = "github.com/weauratech/weaura-terraform-modules//modules/vendorize/monitoring?ref=v2.0.0"

  cluster_name     = module.eks.cluster_name
  region           = var.region
  namespace        = "monitoring"
  create_namespace = true

  # Harbor registry credentials
  harbor_url      = var.harbor_url
  harbor_username = var.harbor_username
  harbor_password = var.harbor_password

  # Pod Identity mode (recommended for Auto Mode)
  cloud_provider = "aws"
  iam_mode       = "pod_identity"
  sizing_preset  = var.sizing_preset

  aws_config = {
    s3_bucket_prefix = var.project_name
  }

  # Extended timeout — Auto Mode cold start requires more time
  # for initial node provisioning (~2-5 min for first pods).
  helm_timeout = 2400

  # Enterprise features
  pdb_enabled                 = true
  alert_rules_enabled         = true
  service_monitor_auto_enable = true

  # Components
  grafana = {
    enabled             = true
    admin_password      = var.grafana_admin_password
    ingress_enabled     = var.grafana_ingress_enabled
    ingress_host        = var.grafana_ingress_host
    storage_size        = "20Gi"
    persistence_enabled = true
  }

  loki       = { enabled = true, storage_size = "50Gi", retention = "30d" }
  mimir      = { enabled = true, storage_size = "100Gi", retention = "90d" }
  tempo      = { enabled = true, storage_size = "50Gi", retention = "720h" }
  prometheus = { enabled = true, storage_size = "50Gi", retention = "15d" }
  pyroscope  = { enabled = true, storage_size = "30Gi" }

  tags = var.tags

  depends_on = [module.eks]
}
