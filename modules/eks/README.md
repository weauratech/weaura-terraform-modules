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
