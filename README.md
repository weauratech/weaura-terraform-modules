# WeAura Terraform Modules

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-623CE4.svg)](https://terraform.io)

Production-ready, reusable Terraform modules for provisioning complex infrastructure and applications across AWS and Azure.

## Available Modules

| Module                                | Description                                                                              | Cloud Support |
| ------------------------------------- | ---------------------------------------------------------------------------------------- | ------------- |
| [grafana-oss](./modules/grafana-oss/) | Complete observability stack with Grafana, Prometheus, Loki, Mimir, Tempo, and Pyroscope | AWS, Azure    |

## Quick Start

### Grafana OSS Stack on AWS

```hcl
module "observability" {
  source = "github.com/WeAura/weaura-terraform-modules//modules/grafana-oss?ref=v1.0.0"

  cloud_provider = "aws"
  environment    = "production"

  # AWS-specific
  aws_region     = "us-east-1"
  eks_cluster_name = "my-cluster"

  # Storage
  create_storage = true

  # Alerting
  alerting_provider      = "slack"
  slack_webhook_url      = var.slack_webhook_url
  slack_webhook_channel  = "#alerts"

  tags = {
    Project     = "my-project"
    Environment = "production"
  }
}
```

### Grafana OSS Stack on Azure

```hcl
module "observability" {
  source = "github.com/WeAura/weaura-terraform-modules//modules/grafana-oss?ref=v1.0.0"

  cloud_provider = "azure"
  environment    = "production"

  # Azure-specific
  azure_resource_group_name = "my-resource-group"
  azure_location            = "eastus"
  aks_cluster_name          = "my-cluster"

  # Storage
  create_storage = true

  # Alerting
  alerting_provider     = "teams"
  teams_webhook_url     = var.teams_webhook_url

  tags = {
    Project     = "my-project"
    Environment = "production"
  }
}
```

## Module Features

### Multi-Cloud Support

All modules are designed to work seamlessly across cloud providers:

| Feature            | AWS                  | Azure                           |
| ------------------ | -------------------- | ------------------------------- |
| Kubernetes         | EKS                  | AKS                             |
| Workload Identity  | IRSA                 | Workload Identity               |
| Object Storage     | S3                   | Azure Blob Storage              |
| Secrets Management | AWS Secrets Manager  | Azure Key Vault                 |
| IAM/RBAC           | IAM Roles + Policies | Managed Identities + Azure RBAC |

### Alerting Providers

- **Slack** - Webhook integration with channel routing
- **Microsoft Teams** - Webhook integration with adaptive cards

## Requirements

- Terraform >= 1.5.0
- Kubernetes cluster (EKS or AKS)
- kubectl configured with cluster access
- Helm 3.x

### Provider Requirements

For AWS:

- AWS CLI configured with appropriate credentials
- IAM permissions for creating roles, policies, and S3 buckets

For Azure:

- Azure CLI configured with appropriate credentials
- Permissions for creating managed identities, storage accounts, and Key Vault access

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development

```bash
# Clone the repository
git clone https://github.com/WeAura/weaura-terraform-modules.git
cd weaura-terraform-modules

# Format code
terraform fmt -recursive

# Validate modules
cd modules/grafana-oss
terraform init
terraform validate
```

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

- Open an [issue](https://github.com/WeAura/weaura-terraform-modules/issues) for bug reports or feature requests
- Check [examples](./modules/grafana-oss/examples/) for usage patterns

## About WeAura

WeAura provides enterprise-grade infrastructure solutions for SRE, DevOps, and Platform Engineering teams.
