# EKS Module

Creates an AWS EKS cluster with support for traditional Managed Node Groups (MNG) or the new EKS Auto Mode. It also includes support for EKS Pod Identity.

## Features

- ✅ **Cluster Management**: Supports Kubernetes version 1.35.
- ✅ **Auto Mode Support**: Optional EKS Auto Mode for simplified compute management.
- ✅ **Managed Node Groups**: Default configuration for managed worker nodes.
- ✅ **Pod Identity Agent**: Automatically enables the EKS Pod Identity Agent addon.
- ✅ **VPC Integration**: Deploys into existing VPC subnets with proper security group configuration.

## Usage

### Standard Managed Node Groups (MNG) Mode

```hcl
module "eks" {
  source = "github.com/WeAura/weaura-terraform-modules//modules/eks?ref=v2.0.0"

  cluster_name       = "my-cluster"
  kubernetes_version = "1.35"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids

  enable_auto_mode = false
  node_group_config = {
    desired_size   = 3
    max_size       = 5
    min_size       = 1
    instance_types = ["t3.xlarge"]
  }

  tags = {
    Environment = "production"
  }
}
```

### EKS Auto Mode

```hcl
module "eks" {
  source = "github.com/WeAura/weaura-terraform-modules//modules/eks?ref=v2.0.0"

  cluster_name = "my-auto-cluster"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids

  enable_auto_mode     = true
  auto_mode_node_pools = ["general-purpose", "system"]

  tags = {
    Environment = "production"
  }
}
```

## Auto Mode vs Managed Node Groups

| Feature | EKS Auto Mode | Managed Node Groups |
|---------|---------------|----------------------|
| **Compute Management** | Automated by AWS (No EC2 instances visible) | User manages ASGs and EC2 nodes |
| **Node Scaling** | Rapid, automated scaling based on pod demand | Scaling based on cluster-autoscaler/Karpenter |
| **Patching/Updates** | Handled automatically by AWS | User manages node image updates |
| **Customization** | Limited to predefined node pools | Full control over EC2 configuration |
| **Complexity** | Low - focuses on pod resource requests | High - requires managing infra layers |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | >= 5.79.0 |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `cluster_name` | Name of the EKS cluster | `string` | n/a |
| `kubernetes_version` | Kubernetes version for the EKS cluster | `string` | `"1.35"` |
| `vpc_id` | VPC ID where the EKS cluster will be deployed | `string` | n/a |
| `subnet_ids` | List of subnet IDs for the cluster and nodes | `list(string)` | n/a |
| `endpoint_public_access` | Whether the API server endpoint is public | `bool` | `true` |
| `enable_auto_mode` | Enable EKS Auto Mode (disables MNG) | `bool` | `false` |
| `auto_mode_node_pools` | List of Auto Mode node pools to enable | `list(string)` | `["general-purpose", "system"]` |
| `enable_pod_identity_agent` | Enable the Pod Identity Agent addon | `bool` | `true` |
| `node_group_config` | Configuration for default MNG | `object` | `{}` |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` |

### `node_group_config` Object
- `desired_size`: Initial number of nodes (default: 3).
- `max_size`: Maximum number of nodes (default: 5).
- `min_size`: Minimum number of nodes (default: 1).
- `instance_types`: List of EC2 instance types (default: `["t3.xlarge"]`).
- `disk_size`: Root volume size in GiB (default: 50).

## Outputs

| Name | Description |
|------|-------------|
| `cluster_name` | Name of the EKS cluster |
| `cluster_endpoint` | Endpoint for the EKS API server |
| `cluster_ca_certificate` | Base64 encoded CA data |
| `cluster_oidc_issuer` | OIDC issuer URL |
| `cluster_security_group_id` | Security group ID attached to the cluster |
| `node_role_arn` | ARN of the IAM role used by EKS nodes |
| `auto_mode_enabled` | Whether EKS Auto Mode is enabled |
| `oidc_provider_arn` | ARN of the IAM OIDC provider for IRSA (empty when Auto Mode) |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.79.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.23.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.79.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.23.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.pod_identity_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_openid_connect_provider.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ebs_csi_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ebs_csi_controller_AmazonEBSCSIDriverPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonEBSCSIDriverPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonEKSBlockStoragePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonEKSComputePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonEKSLoadBalancingPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonEKSNetworkingPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [kubernetes_storage_class_v1.gp3](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [tls_certificate.eks](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_mode_node_pools"></a> [auto\_mode\_node\_pools](#input\_auto\_mode\_node\_pools) | List of Auto Mode node pools to enable | `list(string)` | <pre>[<br>  "general-purpose",<br>  "system"<br>]</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_enable_auto_mode"></a> [enable\_auto\_mode](#input\_enable\_auto\_mode) | Enable EKS Auto Mode (disables traditional managed node groups) | `bool` | `false` | no |
| <a name="input_enable_pod_identity_agent"></a> [enable\_pod\_identity\_agent](#input\_enable\_pod\_identity\_agent) | Enable the EKS Pod Identity Agent addon | `bool` | `true` | no |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | Whether the EKS API server endpoint is publicly accessible | `bool` | `true` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version for the EKS cluster | `string` | `"1.35"` | no |
| <a name="input_node_group_config"></a> [node\_group\_config](#input\_node\_group\_config) | Configuration for the default managed node group | <pre>object({<br>    desired_size   = optional(number, 3)<br>    max_size       = optional(number, 5)<br>    min_size       = optional(number, 1)<br>    instance_types = optional(list(string), ["t3.xlarge"])<br>    disk_size      = optional(number, 50)<br>  })</pre> | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the EKS cluster and node groups | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the EKS cluster will be deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auto_mode_enabled"></a> [auto\_mode\_enabled](#output\_auto\_mode\_enabled) | Whether EKS Auto Mode is enabled |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | Base64 encoded certificate authority data for the cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for the EKS Kubernetes API server |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the EKS cluster |
| <a name="output_cluster_oidc_issuer"></a> [cluster\_oidc\_issuer](#output\_cluster\_oidc\_issuer) | OIDC issuer URL for the EKS cluster |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Security group ID attached to the EKS cluster |
| <a name="output_ebs_csi_controller_role_arn"></a> [ebs\_csi\_controller\_role\_arn](#output\_ebs\_csi\_controller\_role\_arn) | ARN of the IAM role used by the EBS CSI controller (empty when Auto Mode) |
| <a name="output_node_role_arn"></a> [node\_role\_arn](#output\_node\_role\_arn) | ARN of the IAM role used by EKS nodes |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | ARN of the IAM OIDC provider for IRSA (empty when Auto Mode is enabled) |
<!-- END_TF_DOCS -->