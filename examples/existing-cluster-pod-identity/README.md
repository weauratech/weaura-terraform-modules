# Existing Cluster with Pod Identity

Full-featured deployment of the WeAura Monitoring Stack on an existing EKS cluster using EKS Pod Identity. All observability components enabled with enterprise features.

## Pod Identity vs IRSA

| Aspect | Pod Identity | IRSA |
|--------|-------------|------|
| **OIDC Provider** | Not required | Required (configured per cluster) |
| **Setup Complexity** | Lower — uses EKS-native associations | Higher — requires OIDC trust policies |
| **Cross-Account** | Simplified with service account mapping | Requires cross-account OIDC trust |
| **EKS Auto Mode** | Required (only supported method) | Not available in Auto Mode |
| **Minimum EKS Version** | 1.24+ with Pod Identity Agent addon | 1.13+ |

**When to use Pod Identity:**
- New clusters on EKS 1.24+
- EKS Auto Mode clusters (Pod Identity is the only option)
- Simplified IAM management without OIDC provider configuration
- Multi-account setups where cross-account trust is complex with IRSA

**When to use IRSA:**
- Existing clusters already configured with OIDC providers
- Older EKS clusters (< 1.24)
- Environments where Pod Identity Agent addon is not available

## Prerequisites

- Existing EKS cluster (v1.24+) with the **Pod Identity Agent addon** installed
- AWS CLI configured with credentials for IAM, S3, and EKS
- `kubectl` configured for the target cluster
- Harbor registry credentials (provided by WeAura)

To verify the Pod Identity Agent is running:

```bash
kubectl get pods -n kube-system -l app.kubernetes.io/name=eks-pod-identity-agent
```

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `cluster_name` | Name of the existing EKS cluster | `string` | yes |
| `region` | AWS region | `string` | yes |
| `harbor_url` | Harbor registry URL | `string` | yes |
| `harbor_username` | Harbor robot account username | `string` | yes |
| `harbor_password` | Harbor robot account password | `string` | yes |
| `grafana_admin_password` | Grafana admin password | `string` | yes |
| `environment` | Deployment environment | `string` | no |
| `namespace` | Kubernetes namespace | `string` | no |
| `sizing_preset` | Sizing preset (small/medium/large) | `string` | no |
| `s3_bucket_prefix` | Prefix for S3 bucket names | `string` | no |
| `grafana_ingress_enabled` | Enable Grafana Ingress | `bool` | no |
| `grafana_ingress_host` | Grafana Ingress hostname | `string` | no |
| `loki_storage_size` | Loki PV size | `string` | no |
| `loki_retention` | Loki retention period | `string` | no |
| `mimir_storage_size` | Mimir PV size | `string` | no |
| `mimir_retention` | Mimir retention period | `string` | no |
| `tempo_storage_size` | Tempo PV size | `string` | no |
| `tempo_retention` | Tempo retention (Go duration) | `string` | no |
| `prometheus_storage_size` | Prometheus PV size | `string` | no |
| `prometheus_retention` | Prometheus retention period | `string` | no |
| `pyroscope_storage_size` | Pyroscope PV size | `string` | no |
| `additional_helm_values` | Extra Helm values | `map(any)` | no |
| `tags` | AWS resource tags | `map(string)` | no |

## Outputs

| Name | Description |
|------|-------------|
| `namespace` | Kubernetes namespace |
| `grafana_url` | Internal Grafana URL |
| `grafana_ingress_host` | Grafana ingress hostname |
| `loki_url` | Internal Loki URL |
| `mimir_url` | Internal Mimir URL |
| `tempo_url` | Internal Tempo URL |
| `prometheus_url` | Internal Prometheus URL |
| `pyroscope_url` | Internal Pyroscope URL |
| `s3_buckets` | S3 bucket names |
| `iam_role_arn` | IAM role ARN |
| `pod_identity_role_arn` | Pod Identity role ARN |
| `pod_identity_associations` | Pod Identity associations map |
| `helm_release_status` | Helm release status |
| `enabled_components` | Enabled components list |
| `enterprise_features` | Enterprise features map |

## Cleanup

```bash
terraform destroy
```
