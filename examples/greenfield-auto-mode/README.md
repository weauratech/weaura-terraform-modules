# Greenfield Deployment with EKS Auto Mode

Provisions complete AWS infrastructure from scratch — VPC, EKS cluster with **Auto Mode**, and the full WeAura Monitoring Stack — in a single Terraform apply.

## What is EKS Auto Mode?

EKS Auto Mode shifts node lifecycle management entirely to AWS. Instead of defining Managed Node Groups with specific instance types and sizes, you let EKS automatically provision, scale, and update nodes based on workload demand.

**Key differences from Managed Node Groups (MNG):**

| Aspect | Managed Node Groups | Auto Mode |
|--------|--------------------:|----------:|
| Node provisioning | You define instance types & sizes | AWS manages automatically |
| Scaling | ASG-based, you set min/max | Demand-driven, fully automatic |
| StorageClass | Must annotate `gp2` as default | Handled automatically |
| IAM approach | IRSA or Pod Identity | Pod Identity (recommended) |
| Cold start | Nodes pre-provisioned | ~2-5 min for first pods |
| Node updates | You trigger rolling updates | AWS handles patching |

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                          VPC                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │ Public  AZ-a │  │ Public  AZ-b │  │ Public  AZ-c │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │ Private AZ-a │  │ Private AZ-b │  │ Private AZ-c │   │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘   │
│         └──────────────────┼─────────────────┘           │
│                            ▼                             │
│                 ┌────────────────────┐                   │
│                 │    EKS Cluster     │                   │
│                 │    (Auto Mode)     │                   │
│                 │  Nodes on-demand   │                   │
│                 └─────────┬──────────┘                   │
│                           ▼                              │
│              ┌─────────────────────────┐                 │
│              │   Monitoring Stack      │                 │
│              │ Grafana │ Loki │ Mimir  │                 │
│              │ Tempo │ Prom │ Pyro    │                 │
│              └────────────┬────────────┘                 │
└───────────────────────────┼──────────────────────────────┘
                            ▼
                 ┌───────────────────┐
                 │   S3 Buckets      │
                 │ (encrypted, PodId)│
                 └───────────────────┘
```

## Prerequisites

- AWS account with permissions for VPC, EKS, IAM, and S3
- AWS CLI configured with appropriate credentials
- Terraform >= 1.6.0
- Harbor registry credentials (provided by WeAura)

## Estimated Monthly Cost (us-east-1)

| Resource | Estimate |
|----------|----------|
| EKS Cluster | ~$73 |
| NAT Gateway | ~$32 + data transfer |
| Auto Mode Nodes | Variable (pay per use, similar to on-demand EC2) |
| S3 Storage | Variable (pay per use) |
| **Total (base)** | **~$105/month + compute** |

*Auto Mode compute costs depend on workload demand. AWS selects optimal instance types automatically. Expect costs comparable to running 2-4 medium instances for a typical monitoring stack.*

## Cold Start Expectations

When deploying for the first time (or after scaling to zero), Auto Mode needs to provision nodes before pods can be scheduled:

1. **Cluster creation**: ~10-15 minutes (same as MNG)
2. **First node provisioning**: ~2-5 minutes after pods are requested
3. **Helm install**: Uses `helm_timeout = 2400` (40 minutes) to accommodate cold start
4. **Total first deploy**: ~20-25 minutes

Subsequent deployments are faster since nodes may already be warm.

## Usage

1. **Copy and configure variables:**

    ```bash
    cp terraform.tfvars.example terraform.tfvars
    # Edit terraform.tfvars with your values
    ```

2. **Initialize and deploy:**

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

    First deployment takes approximately 20-25 minutes (includes cluster creation and Auto Mode cold start).

3. **Configure kubectl:**

    ```bash
    aws eks update-kubeconfig --name <project_name> --region <region>
    kubectl get nodes   # may take 2-5 min for first node to appear
    kubectl get pods -n monitoring
    ```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `project_name` | Project name for resource naming | `string` | yes |
| `region` | AWS region | `string` | yes |
| `availability_zones` | List of AZs (min 2) | `list(string)` | yes |
| `harbor_url` | Harbor registry URL | `string` | yes |
| `harbor_username` | Harbor robot account username | `string` | yes |
| `harbor_password` | Harbor robot account password | `string` | yes |
| `grafana_admin_password` | Grafana admin password | `string` | yes |
| `vpc_cidr` | VPC CIDR block | `string` | no |
| `kubernetes_version` | EKS Kubernetes version | `string` | no |
| `environment` | Deployment environment | `string` | no |
| `sizing_preset` | Monitoring sizing preset | `string` | no |
| `grafana_ingress_enabled` | Enable Grafana Ingress | `bool` | no |
| `grafana_ingress_host` | Grafana Ingress hostname | `string` | no |
| `tags` | AWS resource tags | `map(string)` | no |

> **Note:** No node sizing variables (desired/min/max, instance types, disk size) are needed. Auto Mode handles all node configuration automatically.

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | VPC ID |
| `private_subnet_ids` | Private subnet IDs |
| `public_subnet_ids` | Public subnet IDs |
| `cluster_name` | EKS cluster name |
| `cluster_endpoint` | EKS API endpoint |
| `cluster_oidc_issuer` | OIDC issuer URL |
| `auto_mode_enabled` | Whether Auto Mode is active |
| `namespace` | Monitoring namespace |
| `grafana_url` | Internal Grafana URL |
| `loki_url` | Internal Loki URL |
| `mimir_url` | Internal Mimir URL |
| `tempo_url` | Internal Tempo URL |
| `prometheus_url` | Internal Prometheus URL |
| `pyroscope_url` | Internal Pyroscope URL |
| `s3_buckets` | S3 bucket names |
| `iam_role_arn` | IAM role ARN |
| `helm_release_status` | Helm release status |
| `enabled_components` | Enabled components list |

## Important Notes

- **No StorageClass annotation**: Unlike the MNG example, Auto Mode manages storage classes automatically. No `kubernetes_annotations` resource is needed.
- **Pod Identity**: This example uses `iam_mode = "pod_identity"` which is the recommended approach for Auto Mode clusters.
- **Helm timeout**: Set to `2400` seconds (40 min) to accommodate the cold start delay when Auto Mode provisions nodes for the first time.
- **State Management**: For production use, uncomment the S3 backend block in `main.tf` and configure remote state.
- **Destroy Order**: `terraform destroy` handles the correct teardown order automatically.

## When to Choose Auto Mode vs. Managed Node Groups

Choose **Auto Mode** when:
- You want minimal operational overhead for node management
- Workloads have variable or unpredictable resource demands
- You prefer AWS to handle node patching and updates
- You are comfortable with a short cold start delay

Choose **Managed Node Groups** when:
- You need specific instance types (e.g., GPU, ARM)
- You require predictable, always-on capacity
- You need fine-grained control over node configuration
- Cold start latency is unacceptable for your use case

## Cleanup

```bash
terraform destroy
```

**Warning:** This will destroy ALL resources including the VPC, EKS cluster, and all monitoring data in S3 buckets.
