# -----------------------------------------------------------------------------
# EKS Cluster
# -----------------------------------------------------------------------------
resource "aws_eks_cluster" "this" {
  name                          = var.cluster_name
  role_arn                      = aws_iam_role.cluster.arn
  version                       = var.kubernetes_version
  bootstrap_self_managed_addons = var.enable_auto_mode ? false : true

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = [aws_security_group.cluster.id]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  dynamic "compute_config" {
    for_each = var.enable_auto_mode ? [1] : []
    content {
      enabled       = true
      node_pools    = var.auto_mode_node_pools
      node_role_arn = aws_iam_role.node[0].arn
    }
  }

  dynamic "storage_config" {
    for_each = var.enable_auto_mode ? [1] : []
    content {
      block_storage { enabled = true }
    }
  }

  dynamic "kubernetes_network_config" {
    for_each = var.enable_auto_mode ? [1] : []
    content {
      elastic_load_balancing { enabled = true }
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
  ]

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Managed Node Group (disabled when Auto Mode is enabled)
# -----------------------------------------------------------------------------
resource "aws_eks_node_group" "default" {
  count           = var.enable_auto_mode ? 0 : 1
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-default"
  node_role_arn   = aws_iam_role.node[0].arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.node_group_config.desired_size
    max_size     = var.node_group_config.max_size
    min_size     = var.node_group_config.min_size
  }

  instance_types = var.node_group_config.instance_types
  disk_size      = var.node_group_config.disk_size
  tags           = var.tags
}

# -----------------------------------------------------------------------------
# Pod Identity Agent Addon
# -----------------------------------------------------------------------------
resource "aws_eks_addon" "pod_identity_agent" {
  count        = var.enable_pod_identity_agent && !var.enable_auto_mode ? 1 : 0
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "eks-pod-identity-agent"
}

# -----------------------------------------------------------------------------
# EBS CSI Driver Addon (MNG only — Auto Mode handles storage via storage_config)
# Required for PVC provisioning on EKS 1.26+ where in-tree EBS is migrated to CSI
# -----------------------------------------------------------------------------
resource "aws_eks_addon" "ebs_csi_driver" {
  count                    = var.enable_auto_mode ? 0 : 1
  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_controller[0].arn

  depends_on = [aws_eks_node_group.default, aws_iam_role_policy_attachment.ebs_csi_controller_AmazonEBSCSIDriverPolicy]
}
