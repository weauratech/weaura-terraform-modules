# Complete Example - WeAura Monitoring Stack

This example demonstrates a complete production deployment of the WeAura monitoring stack with all components enabled on AWS EKS.

## Features Demonstrated

- ✅ All 6 monitoring components enabled (Grafana, Prometheus, Loki, Mimir, Tempo, Pyroscope)
- ✅ AWS integration (S3 storage, IRSA, IAM)
- ✅ Harbor OCI chart distribution
- ✅ Production-ready tagging strategy

## Prerequisites

1. **EKS Cluster**: Running EKS cluster with OIDC provider enabled
2. **kubectl**: Configured to access the cluster
3. **AWS Credentials**: Sufficient permissions for S3, IAM
4. **Harbor Credentials**: For pulling the WeAura monitoring chart (provided by WeAura)

## Usage

### 1. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values.

### 2. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 3. Access Grafana

```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
```

Open http://localhost:3000 — Login with `admin` and your configured password.

## Cleanup

```bash
terraform destroy
```

## References

- [Module Documentation](../../README.md)
- [Grafana Documentation](https://grafana.com/docs/)
