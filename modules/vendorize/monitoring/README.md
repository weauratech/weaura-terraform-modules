# Monitoring Stack Module

Deploys the WeAura Monitoring Stack (weaura-monitoring Helm chart v0.15.0) on AWS EKS. This module provides a complete observability solution with Grafana, Loki, Mimir, Tempo, Prometheus, and Pyroscope.

## Features

- ✅ **Complete Observability Stack**: Grafana, Loki, Mimir, Tempo, Prometheus, Pyroscope
- ✅ **AWS Native Integration**: S3 storage, IRSA, and EKS Pod Identity support
- ✅ **Harbor OCI Registry**: Pulls charts from `registry.dev.weaura.ai/weaura-vendorized`
- ✅ **Sizing Presets**: small, medium, and large presets for rapid deployment
- ✅ **Enterprise Features**: PDBs, built-in alerts, NetworkPolicies, inter-component TLS, Alertmanager, and ServiceMonitors
- ✅ **Secure by Default**: IAM roles for component-level permissions and encrypted S3 buckets

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     EKS Cluster                             │
│                                                             │
│  ┌────────────┐  ┌────────┐  ┌───────┐  ┌───────────────┐ │
│  │  Grafana   │  │  Loki  │  │ Mimir │  │  Prometheus   │ │
│  └─────┬──────┘  └───┬────┘  └───┬───┘  └───────┬───────┘ │
│        │             │           │              │         │
│        └─────────────┴─────┬─────┴──────────────┘         │
│                            │                               │
│            ┌───────────────┴───────────────┐               │
│            ▼                               ▼               │
│      IAM Role (IRSA)            EKS Pod Identity           │
│            │                               │               │
└────────────┼───────────────────────────────┼───────────────┘
             │                               │
             └───────────────┬───────────────┘
                             ▼
            ┌─────────────────────────────────────┐
            │             S3 Buckets              │
            │  ┌──────┬───────┬───────┬──────────┐│
            │  │ Loki │ Mimir │ Tempo │Pyroscope ││
            │  └──────┴───────┴───────┴──────────┘│
            └─────────────────────────────────────┘
                             ▲
                             │ (OCI Pull)
            ┌─────────────────────────────────────┐
            │        Harbor OCI Registry          │
            │   registry.dev.weaura.ai/           │
            │     weaura-vendorized/charts/       │
            └─────────────────────────────────────┘
```

## Usage

### Basic Example (IRSA Mode)

```hcl
module "monitoring_stack" {
  source = "github.com/WeAura/weaura-terraform-modules//modules/vendorize/monitoring?ref=v2.0.0"

  cluster_name = "my-eks-cluster"
  region       = "us-east-1"
  
  # Harbor Credentials
  harbor_url      = "registry.dev.weaura.ai/weaura-vendorized"
  harbor_username = var.harbor_username
  harbor_password = var.harbor_password

  tags = {
    Environment = "production"
  }
}
```

### Pod Identity Mode with Sizing Preset

```hcl
module "monitoring_stack" {
  source = "github.com/WeAura/weaura-terraform-modules//modules/vendorize/monitoring?ref=v2.0.0"

  cluster_name = "my-eks-cluster"
  region       = "us-east-1"
  
  harbor_url      = "registry.dev.weaura.ai/weaura-vendorized"
  harbor_username = var.harbor_username
  harbor_password = var.harbor_password

  iam_mode      = "pod_identity"
  sizing_preset = "medium"

  tags = {
    Environment = "production"
  }
}
```

### Complete Example with Enterprise Features

```hcl
module "monitoring_stack" {
  source = "github.com/WeAura/weaura-terraform-modules//modules/vendorize/monitoring?ref=v2.0.0"

  cluster_name = "production-eks"
  region       = "us-east-1"
  
  harbor_url      = "registry.dev.weaura.ai/weaura-vendorized"
  harbor_username = var.harbor_username
  harbor_password = var.harbor_password

  # Enterprise Features
  pdb_enabled                 = true
  alert_rules_enabled         = true
  network_policy_enabled      = true
  tls_enabled                 = true
  alertmanager_enabled        = true
  service_monitor_auto_enable = true

  # Component Customization
  grafana = {
    enabled         = true
    admin_password  = var.grafana_password
    ingress_enabled = true
    ingress_host    = "grafana.example.com"
  }

  loki = {
    enabled      = true
    storage_size = "100Gi"
    retention    = "60d"
  }

  tags = {
    Environment = "production"
  }
}
```

## IAM Mode: IRSA vs Pod Identity

This module supports two methods for granting IAM permissions to Kubernetes pods:

1.  **IRSA (IAM Roles for Service Accounts)**: The traditional OIDC-based method. Requires an OIDC provider associated with the EKS cluster. Set `iam_mode = "irsa"`.
2.  **Pod Identity**: The modern EKS Pod Identity method. Simplifies IAM role management and does not require OIDC providers. Requires the EKS Pod Identity Agent to be installed on the cluster. Set `iam_mode = "pod_identity"`.

**Note**: The `use_irsa` field in `aws_config` is DEPRECATED. Use the standalone `iam_mode` variable instead.

## Sizing Presets

The `sizing_preset` variable allows for quick configuration of resource requests and limits:

- **small**: For development or test environments.
- **medium**: For staging or small production workloads.
- **large**: For high-traffic production environments.
- **custom**: (Default) Uses the individual component settings and default chart values.

## Enterprise Features

This module includes several enterprise-grade features that are disabled by default:

- **PDB (PodDisruptionBudget)**: Ensures component availability during voluntary disruptions.
- **Built-in Alerts**: Pre-configured alerting rules for component health and resource pressure.
- **Network Policies**: Restricts inter-component traffic to required paths only.
- **Inter-component TLS**: Enables encrypted communication between monitoring components.
- **Alertmanager**: Integration for managing and routing alerts.
- **Service Monitors**: Automatically creates ServiceMonitor resources for Prometheus scraping.

## Component Configuration

### Grafana
- `enabled`: Enable/disable Grafana (default: true).
- `admin_password`: Initial admin password.
- `ingress_enabled`: Enable Kubernetes Ingress for Grafana.
- `ingress_host`: Hostname for the Ingress resource.
- `storage_size`: Size of the persistent volume for Grafana data.
- `persistence_enabled`: Enable persistent storage for Grafana.

### Loki
- `enabled`: Enable/disable Loki (default: true).
- `storage_size`: Size of the persistent volume for Loki data.
- `retention`: Log retention period (e.g., "30d", "24h").

### Mimir
- `enabled`: Enable/disable Mimir (default: true).
- `storage_size`: Size of the persistent volume for Mimir data.
- `retention`: Metrics retention period (e.g., "90d", "30d").

### Tempo
- `enabled`: Enable/disable Tempo (default: true).
- `storage_size`: Size of the persistent volume for Tempo data.
- `retention`: Traces retention period using Go duration format (e.g., "720h", "168h").

### Prometheus
- `enabled`: Enable/disable Prometheus (default: true).
- `storage_size`: Size of the persistent volume for Prometheus data.
- `retention`: Metrics retention period (e.g., "15d").

### Pyroscope
- `enabled`: Enable/disable Pyroscope (default: true).
- `storage_size`: Size of the persistent volume for Pyroscope data.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | >= 5.79.0 |
| kubernetes | ~> 2.25 |
| helm | ~> 2.12 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.79.0 |
| kubernetes | ~> 2.25 |
| helm | ~> 2.12 |

## Prerequisites

1.  **Harbor Access**: Credentials for `registry.dev.weaura.ai` to pull the Helm chart.
2.  **EKS Cluster**: A running EKS cluster.
3.  **IAM Permissions**: Permissions to create IAM roles, policies, and S3 buckets.
4.  **Pod Identity Agent**: Required if using `iam_mode = "pod_identity"`.

## Inputs

### Required Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `cluster_name` | Name of the EKS cluster where monitoring will be deployed | `string` | n/a |
| `region` | AWS region of the EKS cluster | `string` | n/a |
| `harbor_url` | Harbor registry hostname/project (e.g., registry.dev.weaura.ai/weaura-vendorized) | `string` | n/a |
| `harbor_username` | Harbor robot account username for chart pull | `string` | n/a |
| `harbor_password` | Harbor robot account password for chart pull | `string` | n/a |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `chart_version` | Version of weaura-monitoring chart to deploy | `string` | `"0.15.0"` |
| `namespace` | Kubernetes namespace for monitoring stack | `string` | `"monitoring"` |
| `create_namespace` | Create namespace if it doesn't exist | `bool` | `true` |
| `cloud_provider` | Cloud provider (aws or azure) | `string` | `"aws"` |
| `sizing_preset` | Sizing preset for monitoring components (small, medium, large, custom) | `string` | `"custom"` |
| `iam_mode` | IAM strategy for service accounts (irsa, pod_identity) | `string` | `"irsa"` |
| `aws_config` | AWS-specific configuration (s3_bucket_prefix) | `object` | `{}` |
| `grafana` | Grafana configuration object | `object` | See variables.tf |
| `loki` | Loki configuration object | `object` | See variables.tf |
| `mimir` | Mimir configuration object | `object` | See variables.tf |
| `tempo` | Tempo configuration object | `object` | See variables.tf |
| `prometheus` | Prometheus configuration object | `object` | See variables.tf |
| `pyroscope` | Pyroscope configuration object | `object` | See variables.tf |
| `pdb_enabled` | Enable PodDisruptionBudgets | `bool` | `false` |
| `alert_rules_enabled` | Enable built-in alerting rules | `bool` | `false` |
| `alert_rules` | Alert rules configuration | `object` | `{}` |
| `network_policy_enabled` | Enable NetworkPolicies | `bool` | `false` |
| `network_policy_allowed_namespaces` | Namespaces allowed to access monitoring | `list(string)` | `[]` |
| `tls_enabled` | Enable inter-component TLS | `bool` | `false` |
| `tls_cert_manager` | cert-manager configuration for TLS | `object` | `{}` |
| `alertmanager_enabled` | Enable Alertmanager integration | `bool` | `false` |
| `alertmanager_receivers` | Alertmanager receiver configuration | `object` | `{}` |
| `service_monitor_auto_enable` | Automatically enable ServiceMonitors | `bool` | `false` |
| `memberlist_cluster_label` | Label for memberlist cluster grouping | `string` | `""` |
| `helm_values` | Additional Helm values to merge with defaults | `map(any)` | `{}` |
| `tags` | Tags to apply to AWS resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `namespace` | Kubernetes namespace where monitoring stack is deployed |
| `grafana_url` | Internal Grafana service URL (cluster-local) |
| `grafana_admin_username` | Grafana admin username |
| `grafana_ingress_host` | Grafana ingress hostname (if enabled) |
| `loki_url` | Internal Loki service URL |
| `mimir_url` | Internal Mimir service URL |
| `tempo_url` | Internal Tempo service URL |
| `prometheus_url` | Internal Prometheus service URL |
| `pyroscope_url` | Internal Pyroscope service URL |
| `s3_buckets` | S3 bucket names for monitoring components |
| `s3_bucket_arns` | S3 bucket ARNs for monitoring components |
| `iam_mode` | Active IAM strategy (irsa or pod_identity) |
| `iam_role_arn` | IAM role ARN for service accounts |
| `iam_role_name` | IAM role name for service accounts |
| `pod_identity_role_arn` | ARN of the Pod Identity IAM role |
| `pod_identity_associations` | Map of Pod Identity associations |
| `helm_release_name` | Name of the Helm release |
| `helm_release_version` | Version of the deployed Helm chart |
| `helm_release_status` | Status of the Helm release |
| `service_accounts` | Kubernetes service accounts created |
| `cluster_name` | EKS cluster name |
| `region` | AWS region |
| `enabled_components` | List of enabled monitoring components |
| `enterprise_features` | Map of enterprise feature enablement status |
| `sizing_preset` | Active sizing preset |

## Post-Deployment Verification

After deployment, you can verify the status using kubectl:

```bash
# Check Helm release status
helm list -n monitoring

# Check pod status
kubectl get pods -n monitoring

# Verify S3 access (from within a pod if needed)
kubectl exec -it <loki-pod-name> -n monitoring -- ls /data
```

## Troubleshooting

- **Harbor Auth**: Ensure the Harbor robot account has pull permissions and that the `harbor_url` is correct.
- **Pod Identity**: If `iam_mode = "pod_identity"` is used, verify that the Pod Identity Agent is running on your nodes (`kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-eks-pod-identity-agent`).
- **S3 Connectivity**: Ensure your EKS nodes have network access to S3, either via an Internet Gateway or S3 VPC Endpoint.
