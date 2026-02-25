# Complete Example - WeAura Monitoring Stack

This example demonstrates a complete production deployment of the WeAura monitoring stack with all components enabled and additional features like CloudWatch alarms and SNS notifications.

## Features Demonstrated

- ✅ All 6 monitoring components enabled
- ✅ Custom storage sizes and retention periods
- ✅ Grafana ingress configuration
- ✅ CloudWatch alarms for S3 bucket size monitoring
- ✅ SNS topic for alert notifications
- ✅ Production-ready tagging strategy
- ✅ IRSA for secure AWS service access

## Prerequisites

1. **EKS Cluster**: Running EKS cluster with OIDC provider enabled
2. **kubectl**: Configured to access the cluster
3. **AWS Credentials**: Sufficient permissions for S3, IAM, ECR
4. **Terraform Cloud**: Token for accessing the monitoring-stack module

## Usage

### 1. Configure Variables

Copy the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
cluster_name = "production-eks"
region       = "us-east-1"
environment  = "production"
owner        = "platform-team"

# Grafana
grafana_admin_password = "your-secure-password"  # Use secrets manager in production
enable_ingress         = true
grafana_ingress_host   = "grafana.example.com"

# Storage (adjust based on expected usage)
loki_storage_size       = "200Gi"
loki_retention          = "90d"
mimir_storage_size      = "300Gi"
mimir_retention         = "365d"
prometheus_storage_size = "150Gi"
prometheus_retention    = "60d"

# Alerting
enable_sns_alerts = true
alert_email       = "platform-team@example.com"
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan Deployment

```bash
terraform plan
```

### 4. Apply Configuration

```bash
terraform apply
```

### 5. Access Grafana

#### Option A: Port-Forward
```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
```
Open http://localhost:3000

#### Option B: Ingress
If ingress is enabled, access at the configured hostname.

Default credentials:
- Username: `admin`
- Password: Value from `grafana_admin_password` variable

## What Gets Created

### AWS Resources
- **4 S3 Buckets**: Loki, Mimir, Tempo, Pyroscope (with encryption, versioning)
- **IAM Role**: For IRSA with least-privilege permissions
- **IAM Policies**: ECR pull, S3 access
- **CloudWatch Alarms**: S3 bucket size monitoring
- **SNS Topic** (optional): Alert notifications

### Kubernetes Resources
- **Namespace**: `monitoring` (or custom)
- **4 ServiceAccounts**: With IRSA annotations
- **6 Components**: Grafana, Loki, Mimir, Tempo, Prometheus, Pyroscope
- **Helm Release**: weaura-monitoring umbrella chart

## Validation

### 1. Check Pods

All pods should be running:
```bash
kubectl get pods -n monitoring
```

Expected output:
```
NAME                          READY   STATUS    RESTARTS   AGE
grafana-xxx                   1/1     Running   0          5m
loki-xxx                      1/1     Running   0          5m
mimir-xxx                     1/1     Running   0          5m
tempo-xxx                     1/1     Running   0          5m
prometheus-xxx                1/1     Running   0          5m
pyroscope-xxx                 1/1     Running   0          5m
```

### 2. Check Services

```bash
kubectl get svc -n monitoring
```

### 3. Check Helm Release

```bash
helm list -n monitoring
```

### 4. Verify S3 Buckets

```bash
aws s3 ls | grep monitoring
```

### 5. Test Grafana Datasources

Access Grafana and navigate to **Configuration > Data Sources**. All datasources should show green "✓ Data source is working".

## Cost Estimation

**Monthly costs** (example for production workload):

| Resource | Size | Cost/Month |
|----------|------|------------|
| Loki S3 (200Gi) | 200GB | ~$4.60 |
| Mimir S3 (300Gi) | 300GB | ~$6.90 |
| Tempo S3 (100Gi) | 100GB | ~$2.30 |
| Pyroscope S3 (50Gi) | 50GB | ~$1.15 |
| EBS Volumes (6 components) | ~50Gi total | ~$5.00 |
| **Total** | | **~$20-25/month** |

*Excludes compute costs (covered by EKS node costs)*

## Customization

### Adding Custom Helm Values

Use the `additional_helm_values` variable:

```hcl
additional_helm_values = {
  grafana = {
    resources = {
      requests = {
        memory = "512Mi"
        cpu    = "250m"
      }
      limits = {
        memory = "1Gi"
        cpu    = "500m"
      }
    }
  }

  loki = {
    replicas = 3
  }
}
```

### Disabling Components

Set `enabled = false` in the module configuration:

```hcl
module "monitoring_stack" {
  # ... other config ...

  pyroscope = {
    enabled = false
  }
}
```

## Troubleshooting

### Pod Fails to Start

Check events:
```bash
kubectl describe pod -n monitoring <pod-name>
```

Common issues:
- **ImagePullBackOff**: ECR authentication issue
- **CrashLoopBackOff**: S3 permissions or configuration error

### S3 Access Denied

Verify IAM role:
```bash
kubectl describe sa -n monitoring loki
# Check for eks.amazonaws.com/role-arn annotation
```

Test S3 access from pod:
```bash
kubectl run -n monitoring test --rm -it --image amazon/aws-cli \
  --serviceaccount=loki \
  -- s3 ls s3://$(terraform output -raw s3_buckets | jq -r .loki)
```

### Grafana Not Loading Datasources

Check Grafana logs:
```bash
kubectl logs -n monitoring deployment/grafana
```

Verify datasource URLs are reachable:
```bash
kubectl exec -n monitoring deployment/grafana -- curl -I http://loki.monitoring.svc.cluster.local:3100/ready
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all S3 buckets and their contents. If you need to preserve data, manually backup S3 buckets before destroying.

## Next Steps

1. **Configure Dashboards**: Import or create Grafana dashboards
2. **Set Up Alerts**: Configure Grafana alerting rules
3. **Integrate Applications**: Point your apps to Loki, Tempo, Prometheus endpoints
4. **Monitor Costs**: Set up AWS Cost Explorer for monitoring cost trends
5. **Backup Strategy**: Implement backup for Grafana dashboards and alerts

## Support

For issues or questions, contact the WeAura platform team.

## References

- [Main Module Documentation](../../README.md)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [Mimir Documentation](https://grafana.com/docs/mimir/)
- [Tempo Documentation](https://grafana.com/docs/tempo/)
