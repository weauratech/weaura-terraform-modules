# -----------------------------------------------------------------------------
# OIDC Provider for IRSA (IAM Roles for Service Accounts)
# -----------------------------------------------------------------------------
# Creates an IAM OIDC identity provider for the EKS cluster, enabling
# Kubernetes service accounts to assume IAM roles via IRSA.
# Skipped when enable_auto_mode is true (use Pod Identity instead).
# -----------------------------------------------------------------------------

data "tls_certificate" "eks" {
  count = var.enable_auto_mode ? 0 : 1
  url   = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  count = var.enable_auto_mode ? 0 : 1

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-oidc"
    }
  )
}
