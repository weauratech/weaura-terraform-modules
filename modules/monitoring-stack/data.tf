# ============================================================
# Data Sources
# ============================================================

# --------------------------------
# EKS Cluster Information
# --------------------------------

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# --------------------------------
# AWS Account & Region
# --------------------------------

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# --------------------------------
# OIDC Provider for IRSA
# --------------------------------

data "aws_iam_openid_connect_provider" "eks" {
  count = var.aws_config.use_irsa ? 1 : 0

  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# Extract OIDC provider ID from ARN
locals {
  oidc_provider_arn = try(
    data.aws_iam_openid_connect_provider.eks[0].arn,
    ""
  )

  oidc_provider_id = try(
    split("/", local.oidc_provider_arn)[length(split("/", local.oidc_provider_arn)) - 1],
    ""
  )
}
