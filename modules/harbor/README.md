# Harbor Container Registry Terraform Module

This Terraform module deploys [Harbor](https://goharbor.io/) container registry on AWS EKS.

## Features

- **Container Image Storage**: S3 backend with KMS encryption
- **Database**: Internal PostgreSQL (Bitnami subchart)
- **Cache**: Internal Redis (Bitnami subchart)
- **Ingress**: AWS ALB with ACM certificate
- **Security**: IRSA for S3 access, Secrets Manager for credentials
- **Vulnerability Scanning**: Trivy integration
- **High Availability**: Configurable replicas for all components

## Architecture

```
Harbor on EKS:
├── Namespace: harbor
├── Ingress: ALB via AWS Load Balancer Controller
├── TLS: ACM certificate (terminated at ALB)
├── Storage: S3 bucket with SSE-KMS
├── Database: Internal PostgreSQL (Bitnami)
├── Cache: Internal Redis (Bitnami)
├── Scanner: Trivy
├── Secrets: AWS Secrets Manager + External Secrets Operator
└── IRSA: IAM role for S3 access
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | ~> 5.0 |
| kubernetes | ~> 2.25 |
| helm | ~> 2.12 |
| kubectl | ~> 1.14 |
| random | ~> 3.6 |

## Prerequisites

- EKS cluster with OIDC provider configured
- AWS Load Balancer Controller installed
- External Secrets Operator installed with ClusterSecretStore configured
- ACM certificate for Harbor domain

## Usage

### Basic Example

```hcl
module "harbor" {
  source = "git::https://github.com/weaura/weaura-terraform-modules.git//modules/harbor?ref=v1.0.0"

  # General
  project     = "weaura"
  environment = "prod"

  # AWS
  aws_region            = "us-east-2"
  eks_cluster_name      = "eks-weaura-prod"
  eks_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/EXAMPLE"
  eks_oidc_provider_url = "oidc.eks.us-east-2.amazonaws.com/id/EXAMPLE"

  # Harbor
  harbor_external_url = "https://registry.weaura.ai"

  # Ingress
  alb_certificate_arn = "arn:aws:acm:us-east-2:123456789012:certificate/example-cert-id"
  alb_subnets         = "subnet-abc123,subnet-def456"

  # KMS (optional)
  s3_kms_key_arn = "arn:aws:kms:us-east-2:123456789012:key/example-key-id"

  tags = {
    Team = "platform"
  }
}
```

### Production Example with Custom Resources

```hcl
module "harbor" {
  source = "git::https://github.com/weaura/weaura-terraform-modules.git//modules/harbor?ref=v1.0.0"

  # General
  project     = "weaura"
  environment = "prod"

  # AWS
  aws_region            = "us-east-2"
  eks_cluster_name      = "eks-weaura-prod"
  eks_oidc_provider_arn = data.aws_iam_openid_connect_provider.eks.arn
  eks_oidc_provider_url = data.aws_iam_openid_connect_provider.eks.url

  # Harbor
  harbor_external_url  = "https://registry.weaura.ai"
  harbor_chart_version = "1.14.0"

  # Ingress
  alb_certificate_arn = data.aws_acm_certificate.wildcard.arn
  alb_subnets         = join(",", data.aws_subnets.public.ids)
  alb_scheme          = "internet-facing"

  # Storage
  s3_kms_key_arn                       = data.aws_kms_key.main.arn
  s3_lifecycle_enabled                 = true
  s3_lifecycle_transition_ia_days      = 90
  s3_lifecycle_transition_glacier_days = 180

  # Database
  database_storage_size  = "20Gi"
  database_storage_class = "gp3"

  # Redis
  redis_storage_size  = "2Gi"
  redis_storage_class = "gp3"

  # Replicas
  core_replicas       = 2
  registry_replicas   = 2
  jobservice_replicas = 2
  portal_replicas     = 2
  trivy_replicas      = 1

  # Resources
  core_resources = {
    requests = {
      cpu    = "200m"
      memory = "512Mi"
    }
    limits = {
      cpu    = "2"
      memory = "2Gi"
    }
  }

  registry_resources = {
    requests = {
      cpu    = "200m"
      memory = "512Mi"
    }
    limits = {
      cpu    = "4"
      memory = "4Gi"
    }
  }

  # Node scheduling
  node_selector = {
    "node-role" = "platform"
  }

  tolerations = [
    {
      key      = "dedicated"
      operator = "Equal"
      value    = "platform"
      effect   = "NoSchedule"
    }
  ]

  tags = {
    Team        = "platform"
    CostCenter  = "infrastructure"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | Project name for resource naming and tagging | `string` | n/a | yes |
| environment | Environment name (dev, staging, prod) | `string` | n/a | yes |
| aws_region | AWS region for resource deployment | `string` | n/a | yes |
| eks_cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| eks_oidc_provider_arn | ARN of the EKS OIDC provider for IRSA | `string` | n/a | yes |
| eks_oidc_provider_url | URL of the EKS OIDC provider | `string` | n/a | yes |
| harbor_external_url | External URL for Harbor | `string` | n/a | yes |
| harbor_chart_version | Harbor Helm chart version | `string` | `"1.14.0"` | no |
| harbor_namespace | Kubernetes namespace for Harbor | `string` | `"harbor"` | no |
| alb_certificate_arn | ACM certificate ARN for ALB | `string` | `""` | no |
| alb_subnets | Subnet IDs for ALB (comma-separated) | `string` | `""` | no |
| s3_kms_key_arn | KMS key ARN for S3 encryption | `string` | `""` | no |
| enable_trivy | Enable Trivy vulnerability scanner | `bool` | `true` | no |

See [variables.tf](variables.tf) for the complete list of inputs.

## Outputs

| Name | Description |
|------|-------------|
| harbor_url | Harbor external URL |
| harbor_hostname | Harbor hostname (without protocol) |
| harbor_namespace | Kubernetes namespace where Harbor is deployed |
| s3_bucket_name | Name of the S3 bucket for image storage |
| s3_bucket_arn | ARN of the S3 bucket |
| iam_role_arn | ARN of the IAM role for IRSA |
| docker_login_command | Docker login command for Harbor |
| module_summary | Summary of module deployment |

## Post-Deployment

### Configure Docker

```bash
# Login to Harbor
docker login registry.weaura.ai

# Tag and push an image
docker tag myimage:latest registry.weaura.ai/library/myimage:latest
docker push registry.weaura.ai/library/myimage:latest
```

### Configure Kubernetes

```yaml
# Create a pull secret
kubectl create secret docker-registry harbor-pull-secret \
  --docker-server=registry.weaura.ai \
  --docker-username=admin \
  --docker-password=<password>

# Use in a deployment
spec:
  imagePullSecrets:
    - name: harbor-pull-secret
  containers:
    - name: myapp
      image: registry.weaura.ai/library/myimage:latest
```

## Troubleshooting

### Common Issues

1. **ALB not created**: Ensure AWS Load Balancer Controller is installed and has proper IAM permissions
2. **S3 access denied**: Verify IRSA is configured correctly and the service account has the annotation
3. **External Secrets not syncing**: Check ClusterSecretStore configuration and IAM permissions

### Useful Commands

```bash
# Check Harbor pods
kubectl get pods -n harbor

# Check ingress
kubectl get ingress -n harbor

# View Harbor logs
kubectl logs -n harbor deployment/harbor-core

# Check External Secrets
kubectl get externalsecrets -n harbor
```

## License

MIT License - see [LICENSE](../../LICENSE) for details.
