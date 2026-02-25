# Monitoring Stack Module

Terraform module to deploy the WeAura Monitoring Stack (umbrella chart) on AWS EKS clusters. This module provides a complete observability solution with Grafana, Loki, Mimir, Tempo, Prometheus, and Pyroscope.

## Features

- ✅ **Complete Observability Stack**: Grafana, Loki, Mimir, Tempo, Prometheus, Pyroscope
- ✅ **AWS Native Integration**: S3 storage, IRSA authentication, cross-account ECR pull
- ✅ **Auto-Wiring**: Grafana datasources automatically configured
- ✅ **Secure by Default**: IRSA for pod-level IAM permissions, encrypted S3 buckets
- ✅ **Configurable Components**: Enable/disable individual components as needed
- ✅ **Production Ready**: Persistent storage, retention policies, versioning enabled

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     EKS Cluster (Client)                    │
│                                                             │
│  ┌────────────┐  ┌────────┐  ┌───────┐  ┌───────────────┐ │
│  │  Grafana   │  │  Loki  │  │ Mimir │  │  Prometheus   │ │
│  └─────┬──────┘  └───┬────┘  └───┬───┘  └───────┬───────┘ │
│        │             │           │              │         │
│        │   ┌─────────┴───────────┴──────────────┘         │
│        │   │                                               │
│        │   ▼                                               │
│        │  IAM Role (IRSA)                                  │
│        │   │                                               │
└────────┼───┼───────────────────────────────────────────────┘
         │   │
         │   ▼
         │  ┌─────────────────────────────────────┐
         │  │         S3 Buckets (Client)         │
         │  │  ┌──────┬───────┬───────┬──────────┐│
         │  │  │ Loki │ Mimir │ Tempo │Pyroscope ││
         │  │  └──────┴───────┴───────┴──────────┘│
         │  └─────────────────────────────────────┘
         │
         ▼
    ┌─────────────────────────────────────┐
    │    ECR (WeAura Account)             │
    │  weaura-vendorized/charts/          │
    │    weaura-monitoring:0.1.0          │
    └─────────────────────────────────────┘
```

## Usage

### Basic Example

```hcl
module "monitoring_stack" {
  source = "app.terraform.io/weauratech/monitoring-stack/aws"
  version = "1.0.0"

  cluster_name = "my-eks-cluster"
  region       = "us-east-1"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Complete Example with Custom Configuration

```hcl
module "monitoring_stack" {
  source = "app.terraform.io/weauratech/monitoring-stack/aws"
  version = "1.0.0"

  # Cluster Configuration
  cluster_name = "production-eks"
  region       = "us-east-1"

  # Namespace
  namespace        = "monitoring"
  create_namespace = true

  # Grafana Configuration
  grafana = {
    enabled             = true
    admin_password      = var.grafana_admin_password  # Use sensitive variable
    ingress_enabled     = true
    ingress_host        = "grafana.example.com"
    storage_size        = "20Gi"
    persistence_enabled = true
  }

  # Loki Configuration
  loki = {
    enabled      = true
    storage_size = "100Gi"
    retention    = "60d"
  }

  # Mimir Configuration
  mimir = {
    enabled      = true
    storage_size = "200Gi"
    retention    = "180d"
  }

  # Tempo Configuration
  tempo = {
    enabled      = true
    storage_size = "100Gi"
    retention    = "60d"
  }

  # Prometheus Configuration
  prometheus = {
    enabled      = true
    storage_size = "100Gi"
    retention    = "30d"
  }

  # Pyroscope Configuration
  pyroscope = {
    enabled      = true
    storage_size = "50Gi"
  }

  # AWS Configuration
  aws_config = {
    s3_bucket_prefix = "my-company-monitoring"
    use_irsa         = true
  }

  tags = {
    Environment = "production"
    Team        = "platform"
    CostCenter  = "engineering"
  }
}
```

### Minimal Example (Disable Some Components)

```hcl
module "monitoring_stack" {
  source = "app.terraform.io/weauratech/monitoring-stack/aws"
  version = "1.0.0"

  cluster_name = "dev-eks"
  region       = "us-east-2"

  # Only enable Grafana, Loki, and Prometheus
  grafana = {
    enabled = true
  }

  loki = {
    enabled = true
  }

  prometheus = {
    enabled = true
  }

  mimir = {
    enabled = false
  }

  tempo = {
    enabled = false
  }

  pyroscope = {
    enabled = false
  }

  tags = {
    Environment = "development"
  }
}
```

### Using Custom Helm Values

```hcl
module "monitoring_stack" {
  source = "app.terraform.io/weauratech/monitoring-stack/aws"
  version = "1.0.0"

  cluster_name = "production-eks"
  region       = "us-east-1"

  # Override Helm values
  helm_values = {
    grafana = {
      resources = {
        requests = {
          memory = "256Mi"
          cpu    = "200m"
        }
        limits = {
          memory = "512Mi"
          cpu    = "500m"
        }
      }
    }

    loki = {
      replicas = 3
    }
  }

  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 5.0 |
| kubernetes | >= 2.23 |
| helm | >= 2.11 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |
| kubernetes | >= 2.23 |
| helm | >= 2.11 |

## Prerequisites

Before deploying this module, ensure you have:

1. **EKS Cluster**: A running EKS cluster with OIDC provider enabled
2. **kubectl Access**: Ability to create namespaces and deploy resources
3. **IAM Permissions**: 
   - S3: CreateBucket, PutObject, GetObject
   - ECR: GetAuthorizationToken, BatchGetImage, GetDownloadUrlForLayer
   - IAM: CreateRole, CreatePolicy, AttachRolePolicy
4. **Terraform Cloud Access**: Token for module access (contact WeAura team)
5. **Network Configuration**: Ensure pods can reach S3 endpoints (VPC endpoints recommended)

## Inputs

### Required Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `cluster_name` | Name of the EKS cluster | `string` | N/A |
| `region` | AWS region of the EKS cluster | `string` | N/A |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `namespace` | Kubernetes namespace | `string` | `"monitoring"` |
| `create_namespace` | Create namespace if it doesn't exist | `bool` | `true` |
| `ecr_account_id` | AWS account ID where charts are stored | `string` | `"950242546328"` |
| `ecr_region` | AWS region where ECR is located | `string` | `"us-east-2"` |
| `chart_version` | Version of weaura-monitoring chart | `string` | `"0.1.0"` |
| `cloud_provider` | Cloud provider (aws or azure) | `string` | `"aws"` |
| `aws_config` | AWS-specific configuration | `object` | See below |
| `grafana` | Grafana configuration | `object` | See below |
| `loki` | Loki configuration | `object` | See below |
| `mimir` | Mimir configuration | `object` | See below |
| `tempo` | Tempo configuration | `object` | See below |
| `prometheus` | Prometheus configuration | `object` | See below |
| `pyroscope` | Pyroscope configuration | `object` | See below |
| `helm_values` | Additional Helm values | `map(any)` | `{}` |
| `tags` | Tags to apply to AWS resources | `map(string)` | `{}` |

### AWS Configuration Object

```hcl
aws_config = {
  s3_bucket_prefix = ""      # Prefix for S3 buckets (default: "{cluster_name}-monitoring")
  use_irsa         = true    # Use IAM Roles for Service Accounts
}
```

### Component Configuration Objects

Each component (Grafana, Loki, Mimir, Tempo, Prometheus, Pyroscope) has specific configuration:

**Grafana:**
```hcl
grafana = {
  enabled             = true
  admin_password      = ""      # Leave empty for default "admin"
  ingress_enabled     = false
  ingress_host        = ""
  storage_size        = "10Gi"
  persistence_enabled = true
}
```

**Loki:**
```hcl
loki = {
  enabled      = true
  storage_size = "50Gi"
  retention    = "30d"
}
```

**Mimir:**
```hcl
mimir = {
  enabled      = true
  storage_size = "100Gi"
  retention    = "90d"
}
```

**Tempo:**
```hcl
tempo = {
  enabled      = true
  storage_size = "50Gi"
  retention    = "30d"
}
```

**Prometheus:**
```hcl
prometheus = {
  enabled      = true
  storage_size = "50Gi"
  retention    = "15d"
}
```

**Pyroscope:**
```hcl
pyroscope = {
  enabled      = true
  storage_size = "30Gi"
}
```

## Outputs

| Name | Description |
|------|-------------|
| `namespace` | Kubernetes namespace |
| `grafana_url` | Internal Grafana URL |
| `grafana_admin_username` | Grafana admin username |
| `grafana_ingress_host` | Grafana ingress hostname (if enabled) |
| `loki_url` | Internal Loki URL |
| `mimir_url` | Internal Mimir URL |
| `tempo_url` | Internal Tempo URL |
| `prometheus_url` | Internal Prometheus URL |
| `pyroscope_url` | Internal Pyroscope URL |
| `s3_buckets` | Map of S3 bucket names |
| `s3_bucket_arns` | Map of S3 bucket ARNs |
| `iam_role_arn` | IAM role ARN for IRSA |
| `iam_role_name` | IAM role name |
| `helm_release_name` | Helm release name |
| `helm_release_version` | Deployed chart version |
| `helm_release_status` | Helm release status |
| `service_accounts` | Created ServiceAccount names |
| `cluster_name` | EKS cluster name |
| `region` | AWS region |
| `enabled_components` | List of enabled components |

## Post-Deployment

### Accessing Grafana

#### Port-Forward (Quick Access)
```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
```
Open http://localhost:3000
- Username: `admin`
- Password: Value from `var.grafana.admin_password` (or `admin` if not set)

#### Ingress (Production)
If you enabled ingress, access Grafana at the configured hostname.

### Verifying Components

Check all pods are running:
```bash
kubectl get pods -n monitoring
```

Check Helm release:
```bash
helm list -n monitoring
```

Check S3 buckets:
```bash
aws s3 ls | grep monitoring
```

### Grafana Datasources

All datasources are automatically configured:
- **Loki**: Pre-configured for log queries
- **Mimir**: Pre-configured for metrics (alternative to Prometheus)
- **Tempo**: Pre-configured for distributed tracing
- **Prometheus**: Pre-configured for metrics
- **Pyroscope**: Pre-configured for continuous profiling

Navigate to **Configuration > Data Sources** in Grafana to verify.

## Troubleshooting

### Pod Crashes / CrashLoopBackOff

Check pod logs:
```bash
kubectl logs -n monitoring <pod-name> --previous
```

Common issues:
- **S3 Access Denied**: Verify IAM role permissions and IRSA annotation
- **ECR Pull Failed**: Check cross-account ECR policy and authentication
- **Insufficient Resources**: Check node capacity and resource requests

### S3 Access Issues

Verify IRSA configuration:
```bash
kubectl describe sa -n monitoring loki
# Check for eks.amazonaws.com/role-arn annotation
```

Test S3 access from pod:
```bash
kubectl run -n monitoring awscli --rm -it --image amazon/aws-cli -- s3 ls s3://<bucket-name>
```

### ECR Authentication Issues

Get ECR login:
```bash
aws ecr get-login-password --region us-east-2 | helm registry login --username AWS --password-stdin 950242546328.dkr.ecr.us-east-2.amazonaws.com
```

Test chart pull:
```bash
helm pull oci://950242546328.dkr.ecr.us-east-2.amazonaws.com/weaura-vendorized/charts/weaura-monitoring --version 0.1.0
```

### Grafana Not Accessible

Check service:
```bash
kubectl get svc -n monitoring grafana
```

Check ingress (if enabled):
```bash
kubectl get ingress -n monitoring
```

## Security Considerations

### IAM Permissions
- Module creates least-privilege IAM roles via IRSA
- Each component gets only necessary S3 permissions
- ECR pull is scoped to WeAura chart repository only

### S3 Encryption
- All buckets encrypted at rest (AES256)
- Versioning enabled for data recovery
- Server-side encryption enforced

### Network Security
- Components communicate via cluster-local DNS
- No external endpoints exposed by default (except Grafana ingress if enabled)
- Use VPC endpoints for S3 to avoid internet egress

### Secrets Management
- Use sensitive variables for passwords: `sensitive = true`
- Store credentials in AWS Secrets Manager or Parameter Store
- Rotate Grafana admin password regularly

## Cost Optimization

### Storage Costs
- Adjust retention periods based on requirements
- Configure S3 lifecycle policies for older data
- Use S3 Intelligent-Tiering for cost savings

### Compute Costs
- Disable unused components
- Adjust storage sizes based on actual usage
- Use smaller instance types for development

### Monitoring Costs
- S3 storage: ~$0.023/GB/month (us-east-1)
- S3 API requests: Minimal with batching
- EBS volumes: ~$0.10/GB/month

**Example monthly costs** (production workload):
- Loki (100Gi): ~$10/month
- Mimir (200Gi): ~$20/month
- Tempo (100Gi): ~$10/month
- Pyroscope (50Gi): ~$5/month
- **Total**: ~$45-60/month (excluding compute)

## Migration Guide

### From Manual Helm Deployment

1. Export existing Helm values:
```bash
helm get values -n monitoring weaura-monitoring > current-values.yaml
```

2. Convert values to Terraform variables

3. Apply Terraform module (will adopt existing resources)

4. Verify no disruption:
```bash
kubectl get pods -n monitoring
```

### From Other Monitoring Solutions

Contact WeAura support for migration assistance.

## Support

- **Documentation**: https://docs.weaura.io
- **Issues**: Contact WeAura support team
- **Terraform Cloud**: https://app.terraform.io/weauratech

## License

Proprietary - WeAura Technology

---

**Module Version**: 1.0.0  
**Chart Version**: 0.1.0  
**Last Updated**: 2024-02
