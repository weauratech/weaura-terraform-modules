# VPC Module

This module creates a production-ready VPC with public and private subnets, an Internet Gateway, a NAT Gateway, and required route tables. It is designed to be used alongside the EKS module for greenfield deployments.

## Features

- ✅ **Public/Private Subnets**: Distributed across multiple availability zones.
- ✅ **NAT Gateway**: Single NAT Gateway for private subnet egress.
- ✅ **Internet Gateway**: For public subnet access.
- ✅ **EKS Tagging**: Automatically adds `kubernetes.io/cluster/<cluster_name>` tags for proper EKS integration.

## Usage

```hcl
module "vpc" {
  source = "github.com/WeAura/weaura-terraform-modules//modules/vpc?ref=v2.0.0"

  name               = "my-project"
  cluster_name       = "my-eks-cluster"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | >= 5.79.0 |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name` | Name prefix for all resources | `string` | n/a |
| `cluster_name` | Name of the EKS cluster (for subnet tagging) | `string` | n/a |
| `vpc_cidr` | CIDR block for the VPC | `string` | `"10.0.0.0/16"` |
| `availability_zones` | List of availability zones | `list(string)` | n/a |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | The ID of the VPC |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `nat_gateway_id` | The ID of the NAT Gateway |

## Notes

- This module is intended for AWS deployments and follows standard best practices for EKS networking.
- It provides a single NAT Gateway for cost-efficiency. For multi-AZ NAT Gateway high availability, consider a more complex VPC design.
