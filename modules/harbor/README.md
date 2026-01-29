# Harbor Container Registry Terraform Module

This Terraform module deploys [Harbor](https://goharbor.io/) container registry on AWS EKS.

## Features

- **Container Image Storage**: S3 backend with KMS encryption
- **Database**: Internal PostgreSQL (Bitnami subchart)
- **Cache**: Internal Redis (Bitnami subchart)
- **Ingress**: AWS ALB with ACM certificate
- **Security**: IRSA for S3 access, Secrets Manager for credentials
- **Vulnerability Scanning**: Trivy integration
- **High Availability**: Configurable replicas for all components

## Architecture

```
Harbor on EKS:
├── Namespace: harbor
├── Ingress: ALB via AWS Load Balancer Controller
├── TLS: ACM certificate (terminated at ALB)
├── Storage: S3 bucket with SSE-KMS
├── Database: Internal PostgreSQL (Bitnami)
├── Cache: Internal Redis (Bitnami)
├── Scanner: Trivy
├── Secrets: AWS Secrets Manager + External Secrets Operator
└── IRSA: IAM role for S3 access
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | ~> 5.0 |
| kubernetes | ~> 2.25 |
| helm | ~> 2.12 |
| kubectl | ~> 1.14 |
| random | ~> 3.6 |

## Prerequisites

- EKS cluster with OIDC provider configured
- AWS Load Balancer Controller installed
- External Secrets Operator installed with ClusterSecretStore configured
- ACM certificate for Harbor domain

## Usage

### Basic Example

```hcl
module "harbor" {
  source = "git::https://github.com/weaura/weaura-terraform-modules.git//modules/harbor?ref=v1.0.0"

  # General
  project     = "weaura"
  environment = "prod"

  # AWS
  aws_region            = "us-east-2"
  eks_cluster_name      = "eks-weaura-prod"
  eks_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/EXAMPLE"
  eks_oidc_provider_url = "oidc.eks.us-east-2.amazonaws.com/id/EXAMPLE"

  # Harbor
  harbor_external_url = "https://registry.weaura.ai"

  # Ingress
  alb_certificate_arn = "arn:aws:acm:us-east-2:123456789012:certificate/example-cert-id"
  alb_subnets         = "subnet-abc123,subnet-def456"

  # KMS (optional)
  s3_kms_key_arn = "arn:aws:kms:us-east-2:123456789012:key/example-key-id"

  tags = {
    Team = "platform"
  }
}
```

### Production Example with Custom Resources

```hcl
module "harbor" {
  source = "git::https://github.com/weaura/weaura-terraform-modules.git//modules/harbor?ref=v1.0.0"

  # General
  project     = "weaura"
  environment = "prod"

  # AWS
  aws_region            = "us-east-2"
  eks_cluster_name      = "eks-weaura-prod"
  eks_oidc_provider_arn = data.aws_iam_openid_connect_provider.eks.arn
  eks_oidc_provider_url = data.aws_iam_openid_connect_provider.eks.url

  # Harbor
  harbor_external_url  = "https://registry.weaura.ai"
  harbor_chart_version = "1.14.0"

  # Ingress
  alb_certificate_arn = data.aws_acm_certificate.wildcard.arn
  alb_subnets         = join(",", data.aws_subnets.public.ids)
  alb_scheme          = "internet-facing"

  # Storage
  s3_kms_key_arn                       = data.aws_kms_key.main.arn
  s3_lifecycle_enabled                 = true
  s3_lifecycle_transition_ia_days      = 90
  s3_lifecycle_transition_glacier_days = 180

  # Database
  database_storage_size  = "20Gi"
  database_storage_class = "gp3"

  # Redis
  redis_storage_size  = "2Gi"
  redis_storage_class = "gp3"

  # Replicas
  core_replicas       = 2
  registry_replicas   = 2
  jobservice_replicas = 2
  portal_replicas     = 2
  trivy_replicas      = 1

  # Resources
  core_resources = {
    requests = {
      cpu    = "200m"
      memory = "512Mi"
    }
    limits = {
      cpu    = "2"
      memory = "2Gi"
    }
  }

  registry_resources = {
    requests = {
      cpu    = "200m"
      memory = "512Mi"
    }
    limits = {
      cpu    = "4"
      memory = "4Gi"
    }
  }

  # Node scheduling
  node_selector = {
    "node-role" = "platform"
  }

  tolerations = [
    {
      key      = "dedicated"
      operator = "Equal"
      value    = "platform"
      effect   = "NoSchedule"
    }
  ]

  tags = {
    Team        = "platform"
    CostCenter  = "infrastructure"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | Project name for resource naming and tagging | `string` | n/a | yes |
| environment | Environment name (dev, staging, prod) | `string` | n/a | yes |
| aws_region | AWS region for resource deployment | `string` | n/a | yes |
| eks_cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| eks_oidc_provider_arn | ARN of the EKS OIDC provider for IRSA | `string` | n/a | yes |
| eks_oidc_provider_url | URL of the EKS OIDC provider | `string` | n/a | yes |
| harbor_external_url | External URL for Harbor | `string` | n/a | yes |
| harbor_chart_version | Harbor Helm chart version | `string` | `"1.14.0"` | no |
| harbor_namespace | Kubernetes namespace for Harbor | `string` | `"harbor"` | no |
| alb_certificate_arn | ACM certificate ARN for ALB | `string` | `""` | no |
| alb_subnets | Subnet IDs for ALB (comma-separated) | `string` | `""` | no |
| s3_kms_key_arn | KMS key ARN for S3 encryption | `string` | `""` | no |
| enable_trivy | Enable Trivy vulnerability scanner | `bool` | `true` | no |

See [variables.tf](variables.tf) for the complete list of inputs.

## Outputs

| Name | Description |
|------|-------------|
| harbor_url | Harbor external URL |
| harbor_hostname | Harbor hostname (without protocol) |
| harbor_namespace | Kubernetes namespace where Harbor is deployed |
| s3_bucket_name | Name of the S3 bucket for image storage |
| s3_bucket_arn | ARN of the S3 bucket |
| iam_role_arn | ARN of the IAM role for IRSA |
| docker_login_command | Docker login command for Harbor |
| module_summary | Summary of module deployment |

## Post-Deployment

### Configure Docker

```bash
# Login to Harbor
docker login registry.weaura.ai

# Tag and push an image
docker tag myimage:latest registry.weaura.ai/library/myimage:latest
docker push registry.weaura.ai/library/myimage:latest
```

### Configure Kubernetes

```yaml
# Create a pull secret
kubectl create secret docker-registry harbor-pull-secret \
  --docker-server=registry.weaura.ai \
  --docker-username=admin \
  --docker-password=<password>

# Use in a deployment
spec:
  imagePullSecrets:
    - name: harbor-pull-secret
  containers:
    - name: myapp
      image: registry.weaura.ai/library/myimage:latest
```

## Troubleshooting

### Common Issues

1. **ALB not created**: Ensure AWS Load Balancer Controller is installed and has proper IAM permissions
2. **S3 access denied**: Verify IRSA is configured correctly and the service account has the annotation
3. **External Secrets not syncing**: Check ClusterSecretStore configuration and IAM permissions

### Useful Commands

```bash
# Check Harbor pods
kubectl get pods -n harbor

# Check ingress
kubectl get ingress -n harbor

# View Harbor logs
kubectl logs -n harbor deployment/harbor-core

# Check External Secrets
kubectl get externalsecrets -n harbor
```

## License

MIT License - see [LICENSE](../../LICENSE) for details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.12 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.25 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.12 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | ~> 1.14 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.25 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.harbor_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.harbor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.harbor_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.harbor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.harbor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.harbor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.harbor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.harbor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.harbor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_secretsmanager_secret.harbor_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.harbor_secret_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.harbor_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.harbor_secret_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [helm_release.harbor](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.harbor_admin_external_secret](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.harbor_secret_key_external_secret](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_limit_range.harbor](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/limit_range) | resource |
| [kubernetes_namespace.harbor](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_network_policy.harbor](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_resource_quota.harbor](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/resource_quota) | resource |
| [kubernetes_service_account.harbor_registry](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [random_password.database](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.harbor_admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.harbor_secret_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_iam_policy_document.harbor_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.harbor_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.harbor_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_certificate_arn"></a> [alb\_certificate\_arn](#input\_alb\_certificate\_arn) | ACM certificate ARN for ALB HTTPS listener | `string` | `""` | no |
| <a name="input_alb_scheme"></a> [alb\_scheme](#input\_alb\_scheme) | ALB scheme: internet-facing or internal | `string` | `"internet-facing"` | no |
| <a name="input_alb_ssl_policy"></a> [alb\_ssl\_policy](#input\_alb\_ssl\_policy) | SSL policy for ALB HTTPS listener | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| <a name="input_alb_subnets"></a> [alb\_subnets](#input\_alb\_subnets) | Subnet IDs for ALB (comma-separated string) | `string` | `""` | no |
| <a name="input_alb_target_type"></a> [alb\_target\_type](#input\_alb\_target\_type) | ALB target type: ip or instance | `string` | `"ip"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for resource deployment | `string` | n/a | yes |
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | Cloud provider to deploy to (currently only AWS is supported) | `string` | `"aws"` | no |
| <a name="input_core_replicas"></a> [core\_replicas](#input\_core\_replicas) | Number of replicas for Harbor Core | `number` | `2` | no |
| <a name="input_core_resources"></a> [core\_resources](#input\_core\_resources) | Resource requests and limits for Harbor Core | <pre>object({<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | <pre>{<br>  "limits": {<br>    "cpu": "1",<br>    "memory": "1Gi"<br>  },<br>  "requests": {<br>    "cpu": "100m",<br>    "memory": "256Mi"<br>  }<br>}</pre> | no |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Whether to create the S3 bucket for Harbor storage | `bool` | `true` | no |
| <a name="input_create_secrets"></a> [create\_secrets](#input\_create\_secrets) | Whether to create secrets in AWS Secrets Manager | `bool` | `true` | no |
| <a name="input_database_storage_class"></a> [database\_storage\_class](#input\_database\_storage\_class) | Storage class for internal PostgreSQL database | `string` | `"gp3"` | no |
| <a name="input_database_storage_size"></a> [database\_storage\_size](#input\_database\_storage\_size) | Storage size for internal PostgreSQL database | `string` | `"10Gi"` | no |
| <a name="input_database_type"></a> [database\_type](#input\_database\_type) | Database type: internal (Bitnami PostgreSQL in-cluster) | `string` | `"internal"` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#input\_eks\_oidc\_provider\_arn) | ARN of the EKS OIDC provider for IRSA | `string` | n/a | yes |
| <a name="input_eks_oidc_provider_url"></a> [eks\_oidc\_provider\_url](#input\_eks\_oidc\_provider\_url) | URL of the EKS OIDC provider (without https://) | `string` | n/a | yes |
| <a name="input_enable_limit_ranges"></a> [enable\_limit\_ranges](#input\_enable\_limit\_ranges) | Whether to create LimitRanges for the namespace | `bool` | `true` | no |
| <a name="input_enable_network_policies"></a> [enable\_network\_policies](#input\_enable\_network\_policies) | Whether to create NetworkPolicies for the namespace | `bool` | `true` | no |
| <a name="input_enable_resource_quotas"></a> [enable\_resource\_quotas](#input\_enable\_resource\_quotas) | Whether to create ResourceQuotas for the namespace | `bool` | `true` | no |
| <a name="input_enable_trivy"></a> [enable\_trivy](#input\_enable\_trivy) | Enable Trivy vulnerability scanner | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| <a name="input_external_secrets_cluster_store_name"></a> [external\_secrets\_cluster\_store\_name](#input\_external\_secrets\_cluster\_store\_name) | Name of the ClusterSecretStore for External Secrets Operator | `string` | `"aws-secrets-manager"` | no |
| <a name="input_harbor_admin_password"></a> [harbor\_admin\_password](#input\_harbor\_admin\_password) | Harbor admin password (only used if not using Secrets Manager) | `string` | `""` | no |
| <a name="input_harbor_chart_version"></a> [harbor\_chart\_version](#input\_harbor\_chart\_version) | Harbor Helm chart version (chart version, not app version) | `string` | `"1.18.1"` | no |
| <a name="input_harbor_external_url"></a> [harbor\_external\_url](#input\_harbor\_external\_url) | External URL for Harbor (e.g., https://registry.weaura.ai) | `string` | n/a | yes |
| <a name="input_harbor_namespace"></a> [harbor\_namespace](#input\_harbor\_namespace) | Kubernetes namespace for Harbor deployment | `string` | `"harbor"` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Additional annotations for the Ingress resource | `map(string)` | `{}` | no |
| <a name="input_ingress_class"></a> [ingress\_class](#input\_ingress\_class) | Ingress class name (e.g., alb, nginx) | `string` | `"alb"` | no |
| <a name="input_jobservice_replicas"></a> [jobservice\_replicas](#input\_jobservice\_replicas) | Number of replicas for Harbor JobService | `number` | `1` | no |
| <a name="input_jobservice_resources"></a> [jobservice\_resources](#input\_jobservice\_resources) | Resource requests and limits for Harbor JobService | <pre>object({<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | <pre>{<br>  "limits": {<br>    "cpu": "1",<br>    "memory": "1Gi"<br>  },<br>  "requests": {<br>    "cpu": "100m",<br>    "memory": "256Mi"<br>  }<br>}</pre> | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Additional Kubernetes labels to apply to resources | `map(string)` | `{}` | no |
| <a name="input_limit_range"></a> [limit\_range](#input\_limit\_range) | Limit range configuration for Harbor namespace | <pre>object({<br>    default_cpu            = string<br>    default_memory         = string<br>    default_request_cpu    = string<br>    default_request_memory = string<br>    min_cpu                = string<br>    min_memory             = string<br>    max_cpu                = string<br>    max_memory             = string<br>  })</pre> | <pre>{<br>  "default_cpu": "500m",<br>  "default_memory": "512Mi",<br>  "default_request_cpu": "100m",<br>  "default_request_memory": "128Mi",<br>  "max_cpu": "4",<br>  "max_memory": "8Gi",<br>  "min_cpu": "10m",<br>  "min_memory": "16Mi"<br>}</pre> | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource naming (defaults to project name if empty) | `string` | `""` | no |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector) | Node selector for Harbor pods | `map(string)` | `{}` | no |
| <a name="input_portal_replicas"></a> [portal\_replicas](#input\_portal\_replicas) | Number of replicas for Harbor Portal | `number` | `1` | no |
| <a name="input_portal_resources"></a> [portal\_resources](#input\_portal\_resources) | Resource requests and limits for Harbor Portal | <pre>object({<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | <pre>{<br>  "limits": {<br>    "cpu": "500m",<br>    "memory": "256Mi"<br>  },<br>  "requests": {<br>    "cpu": "50m",<br>    "memory": "64Mi"<br>  }<br>}</pre> | no |
| <a name="input_project"></a> [project](#input\_project) | Project name for resource naming and tagging | `string` | n/a | yes |
| <a name="input_redis_storage_class"></a> [redis\_storage\_class](#input\_redis\_storage\_class) | Storage class for internal Redis | `string` | `"gp3"` | no |
| <a name="input_redis_storage_size"></a> [redis\_storage\_size](#input\_redis\_storage\_size) | Storage size for internal Redis | `string` | `"1Gi"` | no |
| <a name="input_redis_type"></a> [redis\_type](#input\_redis\_type) | Redis type: internal (Bitnami Redis in-cluster) | `string` | `"internal"` | no |
| <a name="input_registry_replicas"></a> [registry\_replicas](#input\_registry\_replicas) | Number of replicas for Harbor Registry | `number` | `2` | no |
| <a name="input_registry_resources"></a> [registry\_resources](#input\_registry\_resources) | Resource requests and limits for Harbor Registry | <pre>object({<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | <pre>{<br>  "limits": {<br>    "cpu": "2",<br>    "memory": "2Gi"<br>  },<br>  "requests": {<br>    "cpu": "100m",<br>    "memory": "256Mi"<br>  }<br>}</pre> | no |
| <a name="input_resource_quota"></a> [resource\_quota](#input\_resource\_quota) | Resource quota configuration for Harbor namespace | <pre>object({<br>    requests_cpu    = string<br>    requests_memory = string<br>    limits_cpu      = string<br>    limits_memory   = string<br>    pvcs            = string<br>    services        = string<br>    secrets         = string<br>    configmaps      = string<br>  })</pre> | <pre>{<br>  "configmaps": "50",<br>  "limits_cpu": "16",<br>  "limits_memory": "32Gi",<br>  "pvcs": "20",<br>  "requests_cpu": "8",<br>  "requests_memory": "16Gi",<br>  "secrets": "50",<br>  "services": "20"<br>}</pre> | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket name for Harbor image storage (auto-generated if empty) | `string` | `""` | no |
| <a name="input_s3_kms_key_arn"></a> [s3\_kms\_key\_arn](#input\_s3\_kms\_key\_arn) | KMS key ARN for S3 bucket encryption (uses AES256 if empty) | `string` | `""` | no |
| <a name="input_s3_lifecycle_enabled"></a> [s3\_lifecycle\_enabled](#input\_s3\_lifecycle\_enabled) | Enable lifecycle rules for S3 bucket | `bool` | `true` | no |
| <a name="input_s3_lifecycle_expiration_days"></a> [s3\_lifecycle\_expiration\_days](#input\_s3\_lifecycle\_expiration\_days) | Days before expiring objects (0 to disable) | `number` | `0` | no |
| <a name="input_s3_lifecycle_transition_glacier_days"></a> [s3\_lifecycle\_transition\_glacier\_days](#input\_s3\_lifecycle\_transition\_glacier\_days) | Days before transitioning objects to Glacier storage class | `number` | `180` | no |
| <a name="input_s3_lifecycle_transition_ia_days"></a> [s3\_lifecycle\_transition\_ia\_days](#input\_s3\_lifecycle\_transition\_ia\_days) | Days before transitioning objects to IA storage class | `number` | `90` | no |
| <a name="input_secrets_manager_prefix"></a> [secrets\_manager\_prefix](#input\_secrets\_manager\_prefix) | Prefix for secrets in AWS Secrets Manager | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_tolerations"></a> [tolerations](#input\_tolerations) | Tolerations for Harbor pods | <pre>list(object({<br>    key      = string<br>    operator = string<br>    value    = optional(string)<br>    effect   = string<br>  }))</pre> | `[]` | no |
| <a name="input_trivy_replicas"></a> [trivy\_replicas](#input\_trivy\_replicas) | Number of replicas for Trivy scanner | `number` | `1` | no |
| <a name="input_trivy_resources"></a> [trivy\_resources](#input\_trivy\_resources) | Resource requests and limits for Trivy scanner | <pre>object({<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | <pre>{<br>  "limits": {<br>    "cpu": "2",<br>    "memory": "2Gi"<br>  },<br>  "requests": {<br>    "cpu": "200m",<br>    "memory": "512Mi"<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_docker_login_command"></a> [docker\_login\_command](#output\_docker\_login\_command) | Docker login command for Harbor registry |
| <a name="output_harbor_helm_release_name"></a> [harbor\_helm\_release\_name](#output\_harbor\_helm\_release\_name) | Harbor Helm release name |
| <a name="output_harbor_helm_release_status"></a> [harbor\_helm\_release\_status](#output\_harbor\_helm\_release\_status) | Harbor Helm release status |
| <a name="output_harbor_helm_release_version"></a> [harbor\_helm\_release\_version](#output\_harbor\_helm\_release\_version) | Harbor Helm chart version deployed |
| <a name="output_harbor_hostname"></a> [harbor\_hostname](#output\_harbor\_hostname) | Harbor hostname (without protocol) |
| <a name="output_harbor_namespace"></a> [harbor\_namespace](#output\_harbor\_namespace) | Kubernetes namespace where Harbor is deployed |
| <a name="output_harbor_url"></a> [harbor\_url](#output\_harbor\_url) | Harbor external URL |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM role for Harbor IRSA |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the IAM role for Harbor IRSA |
| <a name="output_ingress_annotations"></a> [ingress\_annotations](#output\_ingress\_annotations) | Ingress annotations applied to Harbor |
| <a name="output_module_summary"></a> [module\_summary](#output\_module\_summary) | Summary of module deployment |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | ARN of the S3 bucket for Harbor image storage |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | Name of the S3 bucket for Harbor image storage |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | Region of the S3 bucket |
| <a name="output_secrets_manager_admin_password_arn"></a> [secrets\_manager\_admin\_password\_arn](#output\_secrets\_manager\_admin\_password\_arn) | ARN of the Secrets Manager secret for Harbor admin password |
| <a name="output_secrets_manager_secret_key_arn"></a> [secrets\_manager\_secret\_key\_arn](#output\_secrets\_manager\_secret\_key\_arn) | ARN of the Secrets Manager secret for Harbor encryption key |
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | Name of the Kubernetes service account with IRSA annotation |
<!-- END_TF_DOCS -->