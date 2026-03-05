# WeAura Terraform Modules

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.6.0-623CE4.svg)](https://terraform.io)

Production-ready, reusable Terraform modules for provisioning observability infrastructure on AWS.

## Available Modules

| Module | Description |
| :--- | :--- |
| [vendorize/monitoring](./modules/vendorize/monitoring/) | Complete observability stack with Grafana, Prometheus, Loki, Mimir, Tempo, and Pyroscope (vendorize namespace for customer deployments). |
| [vpc](./modules/vpc/) | Production-ready VPC with public/private subnets and NAT Gateway. |
| [eks](./modules/eks/) | EKS cluster with support for Auto Mode, Managed Node Groups, and Pod Identity. |

## Quick Start: Monitoring Stack on AWS

```hcl
module "monitoring" {
  source = "github.com/weauratech/weaura-terraform-modules//modules/vendorize/monitoring?ref=v2.0.0"

  cluster_name = "my-cluster"
  region       = "us-east-1"
  
  # Harbor Registry Credentials
  harbor_url      = "registry.dev.weaura.ai/weaura-vendorized"
  harbor_username = var.harbor_username
  harbor_password = var.harbor_password

  # Component Configuration
  sizing_preset = "medium"

  tags = {
    Project     = "my-project"
    Environment = "production"
  }
}
```

## Module Features

### AWS Integration

The modules are optimized for AWS with deep integration into native services:

| Feature | AWS Implementation |
| :--- | :--- |
| **Kubernetes** | Amazon EKS (Managed Node Groups or Auto Mode) |
| **Workload Identity** | IRSA (OIDC) or EKS Pod Identity |
| **Object Storage** | Amazon S3 (Encrypted, Versioned) |
| **Networking** | VPC with Public/Private subnets across multiple AZs |
| **Observability** | WeAura Monitoring Stack (Helm v0.15.0) |

## Examples

| Example | Scenario | What It Provisions |
| :--- | :--- | :--- |
| [minimal](./examples/minimal/) | Fastest way to get started | Monitoring on existing EKS (Grafana + Loki + Prometheus) |
| [existing-cluster-irsa](./examples/existing-cluster-irsa/) | Existing EKS with IRSA | Full monitoring stack with CloudWatch alarms and SNS |
| [existing-cluster-pod-identity](./examples/existing-cluster-pod-identity/) | Existing EKS with Pod Identity | Full monitoring stack using EKS Pod Identity |
| [greenfield-mng](./examples/greenfield-mng/) | No infrastructure yet (MNG) | VPC + EKS (Managed Node Groups) + Monitoring |
| [greenfield-auto-mode](./examples/greenfield-auto-mode/) | No infrastructure yet (Auto Mode) | VPC + EKS Auto Mode v1.35 + Monitoring |

## Requirements

- Terraform >= 1.6.0
- AWS CLI configured with appropriate credentials
- kubectl configured with cluster access
- Helm 3.x
- Harbor credentials for chart distribution (provided by WeAura)

### Provider Requirements

- **AWS CLI**: Configured with appropriate credentials.
- **Permissions**: Sufficient IAM permissions for creating VPCs, EKS clusters, IAM roles, and S3 buckets.
## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development

```bash
# Format code
terraform fmt -recursive

# Validate modules
cd modules/vendorize/monitoring
terraform init
terraform validate
```

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

- Open an [issue](https://github.com/weauratech/weaura-terraform-modules/issues) for bug reports or feature requests.
- Check [examples](./examples/) for usage patterns.

## About WeAura

WeAura provides enterprise-grade infrastructure solutions for SRE, DevOps, and Platform Engineering teams.
