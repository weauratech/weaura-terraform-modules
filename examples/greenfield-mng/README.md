# Greenfield Deployment with Managed Node Groups

Provisions complete AWS infrastructure from scratch — VPC, EKS cluster with Managed Node Groups, and the full WeAura Monitoring Stack — in a single Terraform apply.

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
│                 │  Managed Node Grp  │                   │
│                 │  (t3.xlarge × 3)   │                   │
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
                 │ (encrypted, IRSA) │
                 └───────────────────┘
```

## Prerequisites

- AWS account with permissions for VPC, EKS, IAM, S3, and EC2
- AWS CLI configured with appropriate credentials
- Terraform >= 1.6.0
- Harbor registry credentials (provided by WeAura)

## Estimated Monthly Cost (us-east-1)

| Resource | Estimate |
|----------|----------|
| EKS Cluster | ~$73 |
| NAT Gateway | ~$32 + data transfer |
| EC2 Nodes (3× t3.xlarge) | ~$490 |
| S3 Storage | Variable (pay per use) |
| **Total (base)** | **~$595/month** |

*Costs vary based on data volume, retention, and region.*

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

    Deployment takes approximately 15-20 minutes (EKS cluster creation is the bottleneck).

3. **Configure kubectl:**

    ```bash
    aws eks update-kubeconfig --name <project_name> --region <region>
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
| `node_desired_size` | Desired worker node count | `number` | no |
| `node_max_size` | Maximum worker node count | `number` | no |
| `node_min_size` | Minimum worker node count | `number` | no |
| `node_instance_types` | EC2 instance types | `list(string)` | no |
| `node_disk_size` | Node root volume size (GiB) | `number` | no |
| `environment` | Deployment environment | `string` | no |
| `sizing_preset` | Monitoring sizing preset | `string` | no |
| `grafana_ingress_enabled` | Enable Grafana Ingress | `bool` | no |
| `grafana_ingress_host` | Grafana Ingress hostname | `string` | no |
| `tags` | AWS resource tags | `map(string)` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | VPC ID |
| `private_subnet_ids` | Private subnet IDs |
| `public_subnet_ids` | Public subnet IDs |
| `cluster_name` | EKS cluster name |
| `cluster_endpoint` | EKS API endpoint |
| `cluster_oidc_issuer` | OIDC issuer URL |
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

- **StorageClass**: This example automatically annotates `gp2` as the default StorageClass, which is required for PVCs on fresh MNG clusters.
- **State Management**: For production use, uncomment the S3 backend block in `main.tf` and configure remote state.
- **Destroy Order**: `terraform destroy` handles the correct teardown order automatically.

## Cleanup

```bash
terraform destroy
```

**Warning:** This will destroy ALL resources including the VPC, EKS cluster, and all monitoring data in S3 buckets.
