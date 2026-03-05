# Existing Cluster with IRSA

Full-featured deployment of the WeAura Monitoring Stack on an existing EKS cluster using IAM Roles for Service Accounts (IRSA). Includes all observability components, enterprise features, Grafana ingress, and optional CloudWatch/SNS alerting.

## Prerequisites

- Existing EKS cluster (v1.27+) with OIDC provider configured
- AWS CLI configured with credentials that have permissions for IAM, S3, CloudWatch, and SNS
- `kubectl` configured for the target cluster
- Harbor registry credentials (provided by WeAura)
- (Optional) Ingress controller installed if enabling Grafana ingress
- (Optional) cert-manager installed if using TLS

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Existing EKS Cluster                      │
│                                                             │
│  ┌──────────┐ ┌──────┐ ┌───────┐ ┌───────┐ ┌───────────┐  │
│  │ Grafana  │ │ Loki │ │ Mimir │ │ Tempo │ │Prometheus │  │
│  └────┬─────┘ └──┬───┘ └───┬───┘ └───┬───┘ └─────┬─────┘  │
│       │          │         │         │            │         │
│       └──────────┴────┬────┴─────────┴────────────┘         │
│                       ▼                                     │
│                  IRSA (OIDC)                                │
│                       │                                     │
└───────────────────────┼─────────────────────────────────────┘
                        ▼
          ┌──────────────────────────┐
          │        S3 Buckets        │
          │  Loki │ Mimir │ Tempo │… │
          └──────────────────────────┘
                        │
              ┌─────────┴──────────┐
              ▼                    ▼
      CloudWatch Alarms       SNS Topic
                                  │
                              Email Alert
```

## Usage

1. **Copy and configure variables:**

    ```bash
    cp terraform.tfvars.example terraform.tfvars
    # Edit terraform.tfvars with your values
    ```

2. **Initialize and apply:**

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

3. **Verify deployment:**

    ```bash
    kubectl get pods -n monitoring
    helm list -n monitoring
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
| `enable_cloudwatch_alarms` | Enable S3 CloudWatch alarms | `bool` | no |
| `s3_size_alarm_threshold_gb` | S3 alarm threshold in GB | `number` | no |
| `enable_sns_alerts` | Enable SNS topic for alerts | `bool` | no |
| `alert_email` | Email for SNS notifications | `string` | no |
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
| `helm_release_status` | Helm release status |
| `enabled_components` | Enabled components list |
| `enterprise_features` | Enterprise features map |
| `sns_topic_arn` | SNS topic ARN (if enabled) |

## Cleanup

```bash
terraform destroy
```
