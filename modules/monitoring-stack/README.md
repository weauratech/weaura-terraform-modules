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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | ~> 2.15 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.12 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.25 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | ~> 2.15 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.12 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.25 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.irsa_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.irsa_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [grafana_contact_point.google_chat_application](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point) | resource |
| [grafana_contact_point.google_chat_critical](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point) | resource |
| [grafana_contact_point.google_chat_general](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point) | resource |
| [grafana_contact_point.google_chat_infrastructure](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point) | resource |
| [grafana_contact_point.slack_application](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point) | resource |
| [grafana_contact_point.slack_critical](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point) | resource |
| [grafana_contact_point.slack_general](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point) | resource |
| [grafana_contact_point.slack_infrastructure](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point) | resource |
| [grafana_contact_point.teams_application](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point) | resource |
| [grafana_contact_point.teams_critical](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point) | resource |
| [grafana_contact_point.teams_general](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point) | resource |
| [grafana_contact_point.teams_infrastructure](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point) | resource |
| [grafana_folder.alerts](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.applications](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.custom](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.infrastructure](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.kubernetes](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.loki](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.mimir](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.prometheus](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.pyroscope](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.sre](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.tempo](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder_permission.alerts](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder_permission) | resource |
| [grafana_folder_permission.applications](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder_permission) | resource |
| [grafana_folder_permission.infrastructure](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder_permission) | resource |
| [grafana_folder_permission.kubernetes](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder_permission) | resource |
| [grafana_folder_permission.sre](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder_permission) | resource |
| [grafana_message_template.critical](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/message_template) | resource |
| [grafana_message_template.default](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/message_template) | resource |
| [grafana_mute_timing.maintenance](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/mute_timing) | resource |
| [grafana_notification_policy.main](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/notification_policy) | resource |
| [grafana_rule_group.cluster_alerts](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.deployment_alerts](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.node_alerts](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.persistent_volume_alerts](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.pod_alerts](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [helm_release.mimir](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.monitoring](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.promtail](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.pyroscope](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.tempo](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_limit_range.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/limit_range) | resource |
| [kubernetes_manifest.grafana_tls_external_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_network_policy.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_resource_quota.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/resource_quota) | resource |
| [kubernetes_service_account.workload_identity](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_storage_class.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |
| [aws_iam_policy_document.irsa_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.irsa_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_secretsmanager_secret.grafana_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.slack_webhooks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.grafana_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.slack_webhooks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ACM certificate ARN for HTTPS (AWS ALB ingress only) | `string` | `""` | no |
| <a name="input_alerting_provider"></a> [alerting\_provider](#input\_alerting\_provider) | Alerting provider for notification channels | `string` | `"none"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region (required when cloud\_provider is 'aws') | `string` | `"us-east-1"` | no |
| <a name="input_aws_secrets_path_grafana_admin"></a> [aws\_secrets\_path\_grafana\_admin](#input\_aws\_secrets\_path\_grafana\_admin) | AWS Secrets Manager path for Grafana admin password (AWS only) | `string` | `""` | no |
| <a name="input_aws_secrets_path_prefix"></a> [aws\_secrets\_path\_prefix](#input\_aws\_secrets\_path\_prefix) | Prefix for AWS Secrets Manager paths (AWS only) | `string` | `""` | no |
| <a name="input_aws_secrets_path_slack_webhooks"></a> [aws\_secrets\_path\_slack\_webhooks](#input\_aws\_secrets\_path\_slack\_webhooks) | AWS Secrets Manager path for Slack webhooks (AWS + Slack only) | `string` | `""` | no |
| <a name="input_branding_app_name"></a> [branding\_app\_name](#input\_branding\_app\_name) | Grafana application name shown in UI (grafana.ini: server.app\_name). | `string` | `"Grafana"` | no |
| <a name="input_branding_app_title"></a> [branding\_app\_title](#input\_branding\_app\_title) | Grafana browser tab title and header title (grafana.ini: server.app\_title). | `string` | `"Grafana"` | no |
| <a name="input_branding_css_overrides"></a> [branding\_css\_overrides](#input\_branding\_css\_overrides) | Custom CSS overrides for additional branding. Empty string disables CSS customization. | `string` | `""` | no |
| <a name="input_branding_login_title"></a> [branding\_login\_title](#input\_branding\_login\_title) | Login page title text. | `string` | `"Welcome"` | no |
| <a name="input_branding_logo_url"></a> [branding\_logo\_url](#input\_branding\_logo\_url) | URL to custom logo image (SVG/PNG/JPG). Empty string disables logo replacement. | `string` | `""` | no |
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | Cloud provider to deploy to (aws) | `string` | n/a | yes |
| <a name="input_cluster_issuer"></a> [cluster\_issuer](#input\_cluster\_issuer) | Cert-manager cluster issuer name | `string` | `"letsencrypt-prod"` | no |
| <a name="input_create_storage"></a> [create\_storage](#input\_create\_storage) | Create storage resources (S3 buckets for AWS) | `bool` | `true` | no |
| <a name="input_create_storage_class"></a> [create\_storage\_class](#input\_create\_storage\_class) | Whether to create a dedicated StorageClass with WaitForFirstConsumer binding mode. Set to false if the cluster already has a suitable StorageClass. | `bool` | `true` | no |
| <a name="input_dashboards_path"></a> [dashboards\_path](#input\_dashboards\_path) | Path to dashboards directory. If empty, dashboard provisioning is disabled. | `string` | `""` | no |
| <a name="input_database_type"></a> [database\_type](#input\_database\_type) | Grafana database type: 'sqlite' (default, single-pod only) or 'postgres' (required for HA). | `string` | `"sqlite"` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | EKS cluster name (required when cloud\_provider is 'aws') | `string` | `""` | no |
| <a name="input_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#input\_eks\_oidc\_provider\_arn) | EKS OIDC provider ARN for IRSA (required when cloud\_provider is 'aws') | `string` | `""` | no |
| <a name="input_eks_oidc_provider_url"></a> [eks\_oidc\_provider\_url](#input\_eks\_oidc\_provider\_url) | EKS OIDC provider URL without https:// (required when cloud\_provider is 'aws') | `string` | `""` | no |
| <a name="input_enable_cloudwatch_datasource"></a> [enable\_cloudwatch\_datasource](#input\_enable\_cloudwatch\_datasource) | Enable CloudWatch datasource in Grafana (AWS only) | `bool` | `false` | no |
| <a name="input_enable_default_alert_rules"></a> [enable\_default\_alert\_rules](#input\_enable\_default\_alert\_rules) | Enable default Kubernetes alert rules in Grafana (node, pod, deployment, PVC, cluster) | `bool` | `true` | no |
| <a name="input_enable_grafana"></a> [enable\_grafana](#input\_enable\_grafana) | Enable Grafana deployment | `bool` | `true` | no |
| <a name="input_enable_grafana_resources"></a> [enable\_grafana\_resources](#input\_enable\_grafana\_resources) | Enable Grafana resources (folders, alerting, dashboards). Set to false for initial deploy when Grafana is not yet accessible from the pipeline agent. | `bool` | `false` | no |
| <a name="input_enable_ingress"></a> [enable\_ingress](#input\_enable\_ingress) | Enable ingress for Grafana | `bool` | `true` | no |
| <a name="input_enable_limit_ranges"></a> [enable\_limit\_ranges](#input\_enable\_limit\_ranges) | Enable Kubernetes LimitRanges for each namespace | `bool` | `true` | no |
| <a name="input_enable_log_collector"></a> [enable\_log\_collector](#input\_enable\_log\_collector) | Enable Promtail log collector to ship logs to Loki | `bool` | `false` | no |
| <a name="input_enable_loki"></a> [enable\_loki](#input\_enable\_loki) | Enable Loki deployment | `bool` | `true` | no |
| <a name="input_enable_mimir"></a> [enable\_mimir](#input\_enable\_mimir) | Enable Mimir deployment | `bool` | `true` | no |
| <a name="input_enable_network_policies"></a> [enable\_network\_policies](#input\_enable\_network\_policies) | Enable Kubernetes NetworkPolicies for each namespace | `bool` | `true` | no |
| <a name="input_enable_prometheus"></a> [enable\_prometheus](#input\_enable\_prometheus) | Enable Prometheus (kube-prometheus-stack) deployment | `bool` | `true` | no |
| <a name="input_enable_pyroscope"></a> [enable\_pyroscope](#input\_enable\_pyroscope) | Enable Pyroscope deployment | `bool` | `true` | no |
| <a name="input_enable_resource_quotas"></a> [enable\_resource\_quotas](#input\_enable\_resource\_quotas) | Enable Kubernetes ResourceQuotas for each namespace. Disabled by default to avoid conflicts with Helm atomic deployments. | `bool` | `false` | no |
| <a name="input_enable_tempo"></a> [enable\_tempo](#input\_enable\_tempo) | Enable Tempo deployment | `bool` | `true` | no |
| <a name="input_enable_tls"></a> [enable\_tls](#input\_enable\_tls) | Enable TLS for ingress | `bool` | `true` | no |
| <a name="input_enable_tls_external_secret"></a> [enable\_tls\_external\_secret](#input\_enable\_tls\_external\_secret) | Enable creation of ExternalSecret for TLS certificate sync from AWS Secrets Manager | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, production) | `string` | `"production"` | no |
| <a name="input_excluded_profiling_namespaces"></a> [excluded\_profiling\_namespaces](#input\_excluded\_profiling\_namespaces) | List of namespaces to exclude from profiling | `list(string)` | <pre>[<br>  "kube-system",<br>  "kube-public",<br>  "kube-node-lease",<br>  "cert-manager",<br>  "ingress-nginx"<br>]</pre> | no |
| <a name="input_global_node_selector"></a> [global\_node\_selector](#input\_global\_node\_selector) | Node selector applied to all observability components | `map(string)` | `{}` | no |
| <a name="input_global_tolerations"></a> [global\_tolerations](#input\_global\_tolerations) | Tolerations applied to all observability components | <pre>list(object({<br>    key      = string<br>    operator = string<br>    value    = optional(string)<br>    effect   = string<br>  }))</pre> | `[]` | no |
| <a name="input_google_chat_webhook_application"></a> [google\_chat\_webhook\_application](#input\_google\_chat\_webhook\_application) | Google Chat webhook URL for application alerts | `string` | `""` | no |
| <a name="input_google_chat_webhook_critical"></a> [google\_chat\_webhook\_critical](#input\_google\_chat\_webhook\_critical) | Google Chat webhook URL for critical alerts | `string` | `""` | no |
| <a name="input_google_chat_webhook_general"></a> [google\_chat\_webhook\_general](#input\_google\_chat\_webhook\_general) | Google Chat webhook URL for general alerts | `string` | `""` | no |
| <a name="input_google_chat_webhook_infrastructure"></a> [google\_chat\_webhook\_infrastructure](#input\_google\_chat\_webhook\_infrastructure) | Google Chat webhook URL for infrastructure alerts | `string` | `""` | no |
| <a name="input_grafana_admin_password"></a> [grafana\_admin\_password](#input\_grafana\_admin\_password) | Grafana admin password | `string` | n/a | yes |
| <a name="input_grafana_admin_user"></a> [grafana\_admin\_user](#input\_grafana\_admin\_user) | Grafana admin username | `string` | `"admin"` | no |
| <a name="input_grafana_base_url"></a> [grafana\_base\_url](#input\_grafana\_base\_url) | Base URL for Grafana (for alert action links). Defaults to https://<grafana\_domain> | `string` | `""` | no |
| <a name="input_grafana_chart_version"></a> [grafana\_chart\_version](#input\_grafana\_chart\_version) | Grafana Helm chart version | `string` | `"10.3.1"` | no |
| <a name="input_grafana_domain"></a> [grafana\_domain](#input\_grafana\_domain) | Grafana domain for ingress | `string` | n/a | yes |
| <a name="input_grafana_enable_alerting"></a> [grafana\_enable\_alerting](#input\_grafana\_enable\_alerting) | Enable Grafana Unified Alerting | `bool` | `true` | no |
| <a name="input_grafana_folders"></a> [grafana\_folders](#input\_grafana\_folders) | Map of Grafana folders to create. Key is the folder UID. | <pre>map(object({<br>    title            = string<br>    dashboard_subdir = optional(string, "")<br>  }))</pre> | `{}` | no |
| <a name="input_grafana_node_selector"></a> [grafana\_node\_selector](#input\_grafana\_node\_selector) | Node selector for Grafana pods | `map(string)` | `{}` | no |
| <a name="input_grafana_oauth_api_url"></a> [grafana\_oauth\_api\_url](#input\_grafana\_oauth\_api\_url) | OAuth API/userinfo URL | `string` | `""` | no |
| <a name="input_grafana_oauth_auth_url"></a> [grafana\_oauth\_auth\_url](#input\_grafana\_oauth\_auth\_url) | OAuth authorization URL | `string` | `""` | no |
| <a name="input_grafana_oauth_role_attribute_path"></a> [grafana\_oauth\_role\_attribute\_path](#input\_grafana\_oauth\_role\_attribute\_path) | JMESPath expression for role mapping | `string` | `"contains(groups[*], 'admins') && 'GrafanaAdmin' || 'Viewer'"` | no |
| <a name="input_grafana_oauth_token_url"></a> [grafana\_oauth\_token\_url](#input\_grafana\_oauth\_token\_url) | OAuth token URL | `string` | `""` | no |
| <a name="input_grafana_persistence_enabled"></a> [grafana\_persistence\_enabled](#input\_grafana\_persistence\_enabled) | Enable persistent storage for Grafana | `bool` | `true` | no |
| <a name="input_grafana_plugins"></a> [grafana\_plugins](#input\_grafana\_plugins) | List of Grafana plugins to install | `list(string)` | <pre>[<br>  "grafana-lokiexplore-app",<br>  "grafana-clock-panel",<br>  "grafana-k8s-app"<br>]</pre> | no |
| <a name="input_grafana_resources"></a> [grafana\_resources](#input\_grafana\_resources) | Resource requests and limits for Grafana | <pre>object({<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | <pre>{<br>  "limits": {<br>    "cpu": "1000m",<br>    "memory": "1Gi"<br>  },<br>  "requests": {<br>    "cpu": "200m",<br>    "memory": "512Mi"<br>  }<br>}</pre> | no |
| <a name="input_grafana_sso_allow_assign_grafana_admin"></a> [grafana\_sso\_allow\_assign\_grafana\_admin](#input\_grafana\_sso\_allow\_assign\_grafana\_admin) | Allow SSO role mapping to assign Grafana Server Admin | `bool` | `false` | no |
| <a name="input_grafana_sso_allowed_domains"></a> [grafana\_sso\_allowed\_domains](#input\_grafana\_sso\_allowed\_domains) | Allowed domains for SSO (comma-separated) | `string` | `""` | no |
| <a name="input_grafana_sso_allowed_organizations"></a> [grafana\_sso\_allowed\_organizations](#input\_grafana\_sso\_allowed\_organizations) | Allowed organizations for GitHub SSO (comma-separated) | `string` | `""` | no |
| <a name="input_grafana_sso_client_id"></a> [grafana\_sso\_client\_id](#input\_grafana\_sso\_client\_id) | SSO OAuth Client ID | `string` | `""` | no |
| <a name="input_grafana_sso_client_secret"></a> [grafana\_sso\_client\_secret](#input\_grafana\_sso\_client\_secret) | SSO OAuth Client Secret | `string` | `""` | no |
| <a name="input_grafana_sso_enabled"></a> [grafana\_sso\_enabled](#input\_grafana\_sso\_enabled) | Enable SSO authentication for Grafana | `bool` | `false` | no |
| <a name="input_grafana_sso_provider"></a> [grafana\_sso\_provider](#input\_grafana\_sso\_provider) | SSO provider (google, okta, github) | `string` | `"google"` | no |
| <a name="input_grafana_sso_team_ids"></a> [grafana\_sso\_team\_ids](#input\_grafana\_sso\_team\_ids) | Team IDs for SSO team-based role mapping (comma-separated) | `string` | `""` | no |
| <a name="input_grafana_storage_class"></a> [grafana\_storage\_class](#input\_grafana\_storage\_class) | StorageClass for Grafana PVC. Empty string defaults to var.storage\_class. Use a different class (e.g. EFS) for AZ-agnostic storage. | `string` | `""` | no |
| <a name="input_grafana_storage_size"></a> [grafana\_storage\_size](#input\_grafana\_storage\_size) | Grafana PVC size | `string` | `"40Gi"` | no |
| <a name="input_harbor_password"></a> [harbor\_password](#input\_harbor\_password) | Harbor OCI registry password for pulling the monitoring chart | `string` | `""` | no |
| <a name="input_harbor_username"></a> [harbor\_username](#input\_harbor\_username) | Harbor OCI registry username for pulling the monitoring chart | `string` | `""` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Additional annotations for ingress resources | `map(string)` | `{}` | no |
| <a name="input_ingress_class"></a> [ingress\_class](#input\_ingress\_class) | Ingress class name (e.g., nginx, nginx-private) | `string` | `"nginx"` | no |
| <a name="input_ingress_scheme"></a> [ingress\_scheme](#input\_ingress\_scheme) | ALB scheme - internal or internet-facing (AWS ALB ingress only) | `string` | `"internal"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Additional labels to apply to all Kubernetes resources | `map(string)` | `{}` | no |
| <a name="input_log_collector_target_namespaces"></a> [log\_collector\_target\_namespaces](#input\_log\_collector\_target\_namespaces) | List of Kubernetes namespaces to collect logs from. Empty means all namespaces. | `list(string)` | `[]` | no |
| <a name="input_loki_chart_version"></a> [loki\_chart\_version](#input\_loki\_chart\_version) | Loki Helm chart version | `string` | `"6.48.0"` | no |
| <a name="input_loki_deployment_mode"></a> [loki\_deployment\_mode](#input\_loki\_deployment\_mode) | Loki deployment mode: 'SingleBinary' for small/lightweight deployments (single loki-0 pod), 'SimpleScalable' for medium+ deployments (separate write, read, backend pods with caches). | `string` | `"SingleBinary"` | no |
| <a name="input_loki_replicas"></a> [loki\_replicas](#input\_loki\_replicas) | Number of replicas for Loki components | <pre>object({<br>    write   = number<br>    read    = number<br>    backend = number<br>  })</pre> | <pre>{<br>  "backend": 3,<br>  "read": 3,<br>  "write": 3<br>}</pre> | no |
| <a name="input_loki_resources"></a> [loki\_resources](#input\_loki\_resources) | Resource requests and limits for Loki components | <pre>object({<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | <pre>{<br>  "limits": {<br>    "cpu": "500m",<br>    "memory": "512Mi"<br>  },<br>  "requests": {<br>    "cpu": "100m",<br>    "memory": "256Mi"<br>  }<br>}</pre> | no |
| <a name="input_loki_retention_period"></a> [loki\_retention\_period](#input\_loki\_retention\_period) | Loki log retention period | `string` | `"744h"` | no |
| <a name="input_loki_storage_class"></a> [loki\_storage\_class](#input\_loki\_storage\_class) | StorageClass for Loki PVC. Empty string defaults to var.storage\_class. Use a different class (e.g. EFS) for AZ-agnostic storage. | `string` | `""` | no |
| <a name="input_mimir_chart_version"></a> [mimir\_chart\_version](#input\_mimir\_chart\_version) | Mimir Helm chart version | `string` | `"6.0.5"` | no |
| <a name="input_mimir_replication_factor"></a> [mimir\_replication\_factor](#input\_mimir\_replication\_factor) | Replication factor for Mimir ingesters | `number` | `1` | no |
| <a name="input_mimir_resources"></a> [mimir\_resources](#input\_mimir\_resources) | Resource requests and limits for Mimir components | <pre>object({<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | <pre>{<br>  "limits": {<br>    "cpu": "500m",<br>    "memory": "1Gi"<br>  },<br>  "requests": {<br>    "cpu": "100m",<br>    "memory": "256Mi"<br>  }<br>}</pre> | no |
| <a name="input_mimir_retention_period"></a> [mimir\_retention\_period](#input\_mimir\_retention\_period) | Mimir metrics retention period | `string` | `"365d"` | no |
| <a name="input_monitoring_chart_repository"></a> [monitoring\_chart\_repository](#input\_monitoring\_chart\_repository) | OCI repository URL for the weaura-monitoring umbrella chart | `string` | `"oci://registry.dev.weaura.ai/weaura-vendorized"` | no |
| <a name="input_monitoring_chart_version"></a> [monitoring\_chart\_version](#input\_monitoring\_chart\_version) | Version of the weaura-monitoring umbrella chart | `string` | n/a | yes |
| <a name="input_monitoring_namespace"></a> [monitoring\_namespace](#input\_monitoring\_namespace) | Namespace for the umbrella monitoring stack | `string` | `"monitoring"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for all resource names (defaults to project name) | `string` | `""` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name for resource naming and tagging | `string` | `"observability"` | no |
| <a name="input_prometheus_chart_version"></a> [prometheus\_chart\_version](#input\_prometheus\_chart\_version) | kube-prometheus-stack Helm chart version | `string` | `"68.2.1"` | no |
| <a name="input_prometheus_enable_kube_state_metrics"></a> [prometheus\_enable\_kube\_state\_metrics](#input\_prometheus\_enable\_kube\_state\_metrics) | Enable kube-state-metrics in kube-prometheus-stack | `bool` | `true` | no |
| <a name="input_prometheus_enable_node_exporter"></a> [prometheus\_enable\_node\_exporter](#input\_prometheus\_enable\_node\_exporter) | Enable node-exporter in kube-prometheus-stack | `bool` | `true` | no |
| <a name="input_prometheus_resources"></a> [prometheus\_resources](#input\_prometheus\_resources) | Resource requests and limits for Prometheus | <pre>object({<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | <pre>{<br>  "limits": {<br>    "cpu": "2000m",<br>    "memory": "4Gi"<br>  },<br>  "requests": {<br>    "cpu": "500m",<br>    "memory": "2Gi"<br>  }<br>}</pre> | no |
| <a name="input_prometheus_retention"></a> [prometheus\_retention](#input\_prometheus\_retention) | Local retention period for Prometheus | `string` | `"7d"` | no |
| <a name="input_prometheus_retention_size"></a> [prometheus\_retention\_size](#input\_prometheus\_retention\_size) | Maximum size of Prometheus TSDB | `string` | `"50GB"` | no |
| <a name="input_prometheus_service_monitor_selector"></a> [prometheus\_service\_monitor\_selector](#input\_prometheus\_service\_monitor\_selector) | ServiceMonitor selector labels | `map(string)` | `{}` | no |
| <a name="input_prometheus_storage_size"></a> [prometheus\_storage\_size](#input\_prometheus\_storage\_size) | Prometheus PVC size | `string` | `"80Gi"` | no |
| <a name="input_promtail_chart_version"></a> [promtail\_chart\_version](#input\_promtail\_chart\_version) | Promtail Helm chart version | `string` | `"6.16.6"` | no |
| <a name="input_pyroscope_chart_version"></a> [pyroscope\_chart\_version](#input\_pyroscope\_chart\_version) | Pyroscope Helm chart version | `string` | `"1.18.1"` | no |
| <a name="input_pyroscope_enable_alloy"></a> [pyroscope\_enable\_alloy](#input\_pyroscope\_enable\_alloy) | Enable Grafana Alloy agent for Pyroscope | `bool` | `true` | no |
| <a name="input_pyroscope_persistence_size"></a> [pyroscope\_persistence\_size](#input\_pyroscope\_persistence\_size) | Pyroscope PVC size | `string` | `"50Gi"` | no |
| <a name="input_pyroscope_replicas"></a> [pyroscope\_replicas](#input\_pyroscope\_replicas) | Number of Pyroscope replicas | `number` | `1` | no |
| <a name="input_pyroscope_resources"></a> [pyroscope\_resources](#input\_pyroscope\_resources) | Resource requests and limits for Pyroscope | <pre>object({<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | <pre>{<br>  "limits": {<br>    "cpu": "500m",<br>    "memory": "512Mi"<br>  },<br>  "requests": {<br>    "cpu": "100m",<br>    "memory": "256Mi"<br>  }<br>}</pre> | no |
| <a name="input_retention_loki_hours"></a> [retention\_loki\_hours](#input\_retention\_loki\_hours) | Loki logs retention period in hours (default: 720 = 30 days). | `number` | `720` | no |
| <a name="input_retention_mimir_hours"></a> [retention\_mimir\_hours](#input\_retention\_mimir\_hours) | Mimir metrics retention period in hours (default: 2160 = 90 days). | `number` | `2160` | no |
| <a name="input_retention_pyroscope_hours"></a> [retention\_pyroscope\_hours](#input\_retention\_pyroscope\_hours) | Pyroscope profiles retention period in hours (default: 720 = 30 days). | `number` | `720` | no |
| <a name="input_retention_tempo_hours"></a> [retention\_tempo\_hours](#input\_retention\_tempo\_hours) | Tempo traces retention period in hours (default: 168 = 7 days). | `number` | `168` | no |
| <a name="input_s3_bucket_prefix"></a> [s3\_bucket\_prefix](#input\_s3\_bucket\_prefix) | Prefix for S3 bucket names (AWS only) | `string` | `""` | no |
| <a name="input_s3_buckets"></a> [s3\_buckets](#input\_s3\_buckets) | S3 bucket names for each component (AWS only, optional if create\_storage is true) | <pre>object({<br>    loki_chunks  = optional(string, "")<br>    loki_ruler   = optional(string, "")<br>    mimir_blocks = optional(string, "")<br>    mimir_ruler  = optional(string, "")<br>    tempo        = optional(string, "")<br>  })</pre> | `{}` | no |
| <a name="input_s3_kms_key_arn"></a> [s3\_kms\_key\_arn](#input\_s3\_kms\_key\_arn) | KMS key ARN for S3 bucket encryption. If empty, uses AES256 (AWS-managed keys). Providing a CMK improves security posture. | `string` | `""` | no |
| <a name="input_secrets_provider"></a> [secrets\_provider](#input\_secrets\_provider) | Secrets management provider: 'kubernetes' (plain Secrets) or 'external-secrets' (External Secrets Operator). | `string` | `"kubernetes"` | no |
| <a name="input_slack_channel_application"></a> [slack\_channel\_application](#input\_slack\_channel\_application) | Slack channel for application alerts | `string` | `"#alerts-application"` | no |
| <a name="input_slack_channel_critical"></a> [slack\_channel\_critical](#input\_slack\_channel\_critical) | Slack channel for critical alerts | `string` | `"#alerts-critical"` | no |
| <a name="input_slack_channel_general"></a> [slack\_channel\_general](#input\_slack\_channel\_general) | Slack channel for general alerts | `string` | `"#alerts-general"` | no |
| <a name="input_slack_channel_infrastructure"></a> [slack\_channel\_infrastructure](#input\_slack\_channel\_infrastructure) | Slack channel for infrastructure alerts | `string` | `"#alerts-infrastructure"` | no |
| <a name="input_slack_webhook_application"></a> [slack\_webhook\_application](#input\_slack\_webhook\_application) | Slack webhook URL for application alerts | `string` | `""` | no |
| <a name="input_slack_webhook_critical"></a> [slack\_webhook\_critical](#input\_slack\_webhook\_critical) | Slack webhook URL for critical alerts | `string` | `""` | no |
| <a name="input_slack_webhook_general"></a> [slack\_webhook\_general](#input\_slack\_webhook\_general) | Slack webhook URL for general alerts | `string` | `""` | no |
| <a name="input_slack_webhook_infrastructure"></a> [slack\_webhook\_infrastructure](#input\_slack\_webhook\_infrastructure) | Slack webhook URL for infrastructure alerts | `string` | `""` | no |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | Kubernetes StorageClass name for persistent volumes. If create\_storage\_class is true, this name will be used for the new StorageClass. | `string` | `"weaura-ebs-gp3"` | no |
| <a name="input_storage_class_ebs_type"></a> [storage\_class\_ebs\_type](#input\_storage\_class\_ebs\_type) | EBS volume type for the StorageClass. gp3 is recommended (better baseline performance than gp2 at same cost). | `string` | `"gp3"` | no |
| <a name="input_storage_class_encrypted"></a> [storage\_class\_encrypted](#input\_storage\_class\_encrypted) | Whether EBS volumes should be encrypted at rest. | `bool` | `true` | no |
| <a name="input_storage_class_reclaim_policy"></a> [storage\_class\_reclaim\_policy](#input\_storage\_class\_reclaim\_policy) | Reclaim policy for the StorageClass (Retain or Delete). Retain is recommended for production to prevent accidental data loss. | `string` | `"Retain"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all cloud resources | `map(string)` | `{}` | no |
| <a name="input_teams_webhook_application"></a> [teams\_webhook\_application](#input\_teams\_webhook\_application) | Microsoft Teams webhook URL for application alerts | `string` | `""` | no |
| <a name="input_teams_webhook_critical"></a> [teams\_webhook\_critical](#input\_teams\_webhook\_critical) | Microsoft Teams webhook URL for critical alerts | `string` | `""` | no |
| <a name="input_teams_webhook_general"></a> [teams\_webhook\_general](#input\_teams\_webhook\_general) | Microsoft Teams webhook URL for general alerts | `string` | `""` | no |
| <a name="input_teams_webhook_infrastructure"></a> [teams\_webhook\_infrastructure](#input\_teams\_webhook\_infrastructure) | Microsoft Teams webhook URL for infrastructure alerts | `string` | `""` | no |
| <a name="input_tempo_chart_version"></a> [tempo\_chart\_version](#input\_tempo\_chart\_version) | Tempo Helm chart version | `string` | `"1.61.3"` | no |
| <a name="input_tempo_resources"></a> [tempo\_resources](#input\_tempo\_resources) | Resource requests and limits for Tempo components | <pre>object({<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | <pre>{<br>  "limits": {<br>    "cpu": "500m",<br>    "memory": "512Mi"<br>  },<br>  "requests": {<br>    "cpu": "100m",<br>    "memory": "256Mi"<br>  }<br>}</pre> | no |
| <a name="input_tempo_retention_period"></a> [tempo\_retention\_period](#input\_tempo\_retention\_period) | Tempo traces retention period | `string` | `"168h"` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Unique tenant identifier (lowercase alphanumeric + hyphens only). Used for S3 bucket paths, namespace naming, IAM role naming. | `string` | n/a | yes |
| <a name="input_tenant_name"></a> [tenant\_name](#input\_tenant\_name) | Human-readable tenant name (e.g., 'ACME Corporation'). Used for resource tagging and documentation. | `string` | n/a | yes |
| <a name="input_tls_external_secret_config"></a> [tls\_external\_secret\_config](#input\_tls\_external\_secret\_config) | Configuration for TLS ExternalSecret | <pre>object({<br>    cluster_secret_store_name = optional(string, "")<br>    key_vault_cert_name       = optional(string, "")<br>    secret_refresh_interval   = optional(string, "1h")<br>  })</pre> | `{}` | no |
| <a name="input_tls_secret_name"></a> [tls\_secret\_name](#input\_tls\_secret\_name) | Name of the TLS secret for ingress (if using cert-manager or pre-created secret) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alerting_configuration"></a> [alerting\_configuration](#output\_alerting\_configuration) | Alerting configuration summary |
| <a name="output_aws_iam_role_arns"></a> [aws\_iam\_role\_arns](#output\_aws\_iam\_role\_arns) | ARNs of IAM roles for IRSA (AWS only) |
| <a name="output_aws_s3_bucket_arns"></a> [aws\_s3\_bucket\_arns](#output\_aws\_s3\_bucket\_arns) | ARNs of S3 buckets created (AWS only) |
| <a name="output_aws_s3_bucket_names"></a> [aws\_s3\_bucket\_names](#output\_aws\_s3\_bucket\_names) | Names of S3 buckets created (AWS only) |
| <a name="output_datasource_urls"></a> [datasource\_urls](#output\_datasource\_urls) | Map of all datasource URLs for Grafana configuration |
| <a name="output_grafana_admin_user"></a> [grafana\_admin\_user](#output\_grafana\_admin\_user) | Grafana admin username |
| <a name="output_grafana_folder_uids"></a> [grafana\_folder\_uids](#output\_grafana\_folder\_uids) | UIDs of Grafana folders created |
| <a name="output_grafana_helm_release_name"></a> [grafana\_helm\_release\_name](#output\_grafana\_helm\_release\_name) | Grafana Helm release name |
| <a name="output_grafana_helm_release_version"></a> [grafana\_helm\_release\_version](#output\_grafana\_helm\_release\_version) | Grafana Helm chart version deployed |
| <a name="output_grafana_namespace"></a> [grafana\_namespace](#output\_grafana\_namespace) | Kubernetes namespace where Grafana is deployed |
| <a name="output_grafana_url"></a> [grafana\_url](#output\_grafana\_url) | Grafana URL |
| <a name="output_helm_releases"></a> [helm\_releases](#output\_helm\_releases) | Status of all Helm releases |
| <a name="output_loki_helm_release_name"></a> [loki\_helm\_release\_name](#output\_loki\_helm\_release\_name) | Loki Helm release name |
| <a name="output_loki_namespace"></a> [loki\_namespace](#output\_loki\_namespace) | Kubernetes namespace where Loki is deployed |
| <a name="output_loki_url"></a> [loki\_url](#output\_loki\_url) | Loki internal service URL |
| <a name="output_mimir_helm_release_name"></a> [mimir\_helm\_release\_name](#output\_mimir\_helm\_release\_name) | Mimir Helm release name |
| <a name="output_mimir_namespace"></a> [mimir\_namespace](#output\_mimir\_namespace) | Kubernetes namespace where Mimir is deployed |
| <a name="output_mimir_push_url"></a> [mimir\_push\_url](#output\_mimir\_push\_url) | Mimir push endpoint for remote write |
| <a name="output_mimir_url"></a> [mimir\_url](#output\_mimir\_url) | Mimir internal service URL (query endpoint) |
| <a name="output_module_summary"></a> [module\_summary](#output\_module\_summary) | Summary of module deployment |
| <a name="output_namespaces"></a> [namespaces](#output\_namespaces) | Monitoring namespace (all components share a single namespace) |
| <a name="output_prometheus_helm_release_name"></a> [prometheus\_helm\_release\_name](#output\_prometheus\_helm\_release\_name) | Prometheus Helm release name |
| <a name="output_prometheus_namespace"></a> [prometheus\_namespace](#output\_prometheus\_namespace) | Kubernetes namespace where Prometheus is deployed |
| <a name="output_prometheus_url"></a> [prometheus\_url](#output\_prometheus\_url) | Prometheus internal service URL |
| <a name="output_pyroscope_helm_release_name"></a> [pyroscope\_helm\_release\_name](#output\_pyroscope\_helm\_release\_name) | Pyroscope Helm release name |
| <a name="output_pyroscope_namespace"></a> [pyroscope\_namespace](#output\_pyroscope\_namespace) | Kubernetes namespace where Pyroscope is deployed |
| <a name="output_pyroscope_url"></a> [pyroscope\_url](#output\_pyroscope\_url) | Pyroscope internal service URL |
| <a name="output_storage_configuration"></a> [storage\_configuration](#output\_storage\_configuration) | Cloud-agnostic storage configuration summary |
| <a name="output_tempo_helm_release_name"></a> [tempo\_helm\_release\_name](#output\_tempo\_helm\_release\_name) | Tempo Helm release name |
| <a name="output_tempo_namespace"></a> [tempo\_namespace](#output\_tempo\_namespace) | Kubernetes namespace where Tempo is deployed |
| <a name="output_tempo_url"></a> [tempo\_url](#output\_tempo\_url) | Tempo internal service URL |
<!-- END_TF_DOCS -->