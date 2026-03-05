# ============================================================
# Minimal Example - WeAura Monitoring Stack
# ============================================================
# Quickest way to deploy monitoring on an existing EKS cluster.
# Only required variables — everything else uses defaults.
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

provider "aws" {
  region = var.region
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

module "monitoring" {
  source = "github.com/weauratech/weaura-terraform-modules//modules/vendorize/monitoring?ref=v2.0.0"

  cluster_name = var.cluster_name
  region       = var.region

  harbor_url      = var.harbor_url
  harbor_username = var.harbor_username
  harbor_password = var.harbor_password

  sizing_preset = "small"

  grafana    = { enabled = true }
  loki       = { enabled = true }
  prometheus = { enabled = true }
  mimir      = { enabled = false }
  tempo      = { enabled = false }
  pyroscope  = { enabled = false }

  tags = var.tags
}
