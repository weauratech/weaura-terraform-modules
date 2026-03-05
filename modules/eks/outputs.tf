output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS Kubernetes API server"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate authority data for the cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL for the EKS cluster"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.cluster.id
}

output "node_role_arn" {
  description = "ARN of the IAM role used by EKS nodes"
  value       = aws_iam_role.node[0].arn
}

output "auto_mode_enabled" {
  description = "Whether EKS Auto Mode is enabled"
  value       = var.enable_auto_mode
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider for IRSA (empty when Auto Mode is enabled)"
  value       = try(aws_iam_openid_connect_provider.eks[0].arn, "")
}

output "ebs_csi_controller_role_arn" {
  description = "ARN of the IAM role used by the EBS CSI controller (empty when Auto Mode)"
  value       = try(aws_iam_role.ebs_csi_controller[0].arn, "")
}
