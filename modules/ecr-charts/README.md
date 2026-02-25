# ECR Charts Module

Terraform module to manage Amazon ECR repositories for storing Helm charts as OCI artifacts.

## Features

- ✅ **ECR Repository Management**: Creates ECR repositories for each Helm chart
- ✅ **Cross-Account Access**: Configurable IAM policies for multi-account pull access
- ✅ **Lifecycle Policies**: Automatic cleanup of old chart versions
- ✅ **Image Scanning**: Security scanning on push
- ✅ **Encryption**: Support for AES256 and KMS encryption
- ✅ **Immutable Tags**: Prevents tag overwrites for security

## Usage

### Basic Example

```hcl
module "ecr_charts" {
  source = "app.terraform.io/weauratech/ecr-charts/aws"
  version = "1.0.0"

  charts = {
    weaura-monitoring = {
      name        = "weaura-monitoring"
      description = "WeAura monitoring stack umbrella chart"
    }
  }

  repository_prefix = "weaura-vendorized/charts"
  
  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Cross-Account Access Example

```hcl
module "ecr_charts" {
  source = "app.terraform.io/weauratech/ecr-charts/aws"
  version = "1.0.0"

  charts = {
    weaura-monitoring = {
      name        = "weaura-monitoring"
      description = "Monitoring stack"
    }
  }

  # Allow specific AWS accounts to pull
  cross_account_pull_principals = [
    "arn:aws:iam::123456789012:root",
    "arn:aws:iam::987654321098:root"
  ]

  lifecycle_policy_rules = {
    max_image_count = 20  # Keep last 20 versions
  }
}
```

### KMS Encryption Example

```hcl
module "ecr_charts" {
  source = "app.terraform.io/weauratech/ecr-charts/aws"
  version = "1.0.0"

  charts = {
    weaura-monitoring = {
      name = "weaura-monitoring"
    }
  }

  encryption_type = "KMS"
  kms_key_arn     = aws_kms_key.ecr.arn
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| charts | Map of Helm charts to create ECR repositories for | `map(object)` | n/a | yes |
| repository_prefix | Prefix for ECR repository names | `string` | `"weaura-vendorized/charts"` | no |
| scan_on_push | Enable image scanning on push | `bool` | `true` | no |
| encryption_type | Encryption type (AES256 or KMS) | `string` | `"AES256"` | no |
| kms_key_arn | ARN of KMS key (required if encryption_type is KMS) | `string` | `null` | no |
| lifecycle_policy_rules | Lifecycle policy configuration | `object` | `{max_image_count = 10}` | no |
| cross_account_pull_principals | AWS account IDs/ARNs allowed to pull | `list(string)` | `["*"]` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_urls | Map of chart names to ECR repository URLs |
| repository_arns | Map of chart names to ECR repository ARNs |
| registry_id | ECR registry ID (AWS account ID) |
| oci_urls | Map of chart names to full OCI URLs for Helm |
| pull_commands | Map of chart names to example Helm pull commands |

## Publishing Charts

After creating repositories, publish charts using:

```bash
# Login to ECR
aws ecr get-login-password --region us-east-2 | \
  helm registry login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-2.amazonaws.com

# Push chart
helm push my-chart-1.0.0.tgz oci://ACCOUNT_ID.dkr.ecr.us-east-2.amazonaws.com/weaura-vendorized/charts
```

## Cross-Account Pull Setup (Client Side)

Clients need IAM permissions to pull from your ECR:

```hcl
# In client's AWS account
resource "aws_iam_policy" "ecr_pull" {
  name = "WeAuraECRPull"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "arn:aws:ecr:REGION:YOUR_ACCOUNT_ID:repository/weaura-vendorized/charts/*"
      }
    ]
  })
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |

## License

Proprietary - WeAura Technology
