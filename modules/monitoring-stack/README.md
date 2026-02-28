# WeAura Monitoring Stack - Terraform Module

Production-ready observability stack for AWS EKS clusters, deployed via Harbor OCI Helm chart.

## Architecture

```
aura-platform-foundation (terragrunt)
  └── weaura-terraform-modules//modules/monitoring-stack (this module)
       └── Harbor OCI chart: oci://registry.dev.weaura.ai/weaura-vendorized/weaura-monitoring
```

## Components

| Component | Description | Toggle |
|-----------|-------------|--------|
| Grafana | Visualization & dashboards | `enable_grafana` |
| Prometheus | Metrics collection (kube-prometheus-stack) | `enable_prometheus` |
| Loki | Log aggregation (SingleBinary or SimpleScalable) | `enable_loki` |
| Mimir | Long-term metrics storage | `enable_mimir` |
| Tempo | Distributed tracing | `enable_tempo` |
| Pyroscope | Continuous profiling | `enable_pyroscope` |
| Promtail | Log collector | `enable_log_collector` |

## Usage

```hcl
module "monitoring" {
  source = "git::https://github.com/weauratech/weaura-terraform-modules.git//modules/monitoring-stack?ref=modules/monitoring-stack/v2.0.0"

  # Required
  cloud_provider          = "aws"
  environment             = "production"
  tenant_id               = "acme-corp"
  tenant_name             = "ACME Corporation"
  grafana_domain          = "grafana.acme.com"
  grafana_admin_password  = var.grafana_admin_password
  monitoring_chart_version = "0.1.10"

  # Harbor OCI auth
  harbor_username = var.harbor_username
  harbor_password = var.harbor_password

  # AWS
  aws_region             = "us-east-2"
  eks_cluster_name       = "my-cluster"
  eks_oidc_provider_arn  = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  eks_oidc_provider_url  = data.aws_eks_cluster.this.identity[0].oidc[0].issuer

  # Component toggles
  enable_grafana    = true
  enable_prometheus = true
  enable_loki       = true
  enable_mimir      = false
  enable_tempo      = false
  enable_pyroscope  = false

  # Loki mode
  loki_deployment_mode = "SingleBinary"  # or "SimpleScalable"
}
```

## Harbor Chart Distribution

Charts are distributed as OCI artifacts from Harbor:
- Registry: `registry.dev.weaura.ai`
- Project: `weaura-vendorized`
- Chart: `weaura-monitoring`

## License

AGPL-3.0
