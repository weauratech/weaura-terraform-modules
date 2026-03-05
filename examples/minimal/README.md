# Minimal Example

Simplest possible deployment of the WeAura Monitoring Stack on an existing EKS cluster. Deploys Grafana, Loki, and Prometheus with the `small` sizing preset.

## Prerequisites

- Existing EKS cluster with `kubectl` access configured
- AWS CLI configured with appropriate credentials
- Harbor registry credentials (provided by WeAura)

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
| `region` | AWS region of the EKS cluster | `string` | yes |
| `harbor_url` | Harbor registry URL | `string` | yes |
| `harbor_username` | Harbor robot account username | `string` | yes |
| `harbor_password` | Harbor robot account password | `string` | yes |
| `tags` | Tags to apply to AWS resources | `map(string)` | no |

## Outputs

| Name | Description |
|------|-------------|
| `grafana_url` | Internal Grafana service URL |
| `loki_url` | Internal Loki service URL |
| `prometheus_url` | Internal Prometheus service URL |
| `namespace` | Kubernetes namespace |
| `helm_release_status` | Status of the Helm release |

## Cleanup

```bash
terraform destroy
```
