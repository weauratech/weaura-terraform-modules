# -----------------------------------------------------------------------------
# EKS Auto Mode Default StorageClass (gp3)
# 
# EKS Auto Mode creates a gp2 StorageClass with the legacy kubernetes.io/aws-ebs
# provisioner but does NOT mark it as default. Additionally, no StorageClass exists
# for the Auto Mode EBS CSI driver (ebs.csi.eks.amazonaws.com). This causes PVCs
# without an explicit storageClassName to remain Pending indefinitely.
#
# This resource ensures a production-ready default gp3 StorageClass is automatically
# created when Auto Mode is enabled, using the correct Auto Mode CSI driver.
# 
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html
# -----------------------------------------------------------------------------

resource "kubernetes_storage_class_v1" "gp3" {
  count = var.enable_auto_mode ? 1 : 0

  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.eks.amazonaws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  reclaim_policy      = "Delete"

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  depends_on = [aws_eks_cluster.this]
}
