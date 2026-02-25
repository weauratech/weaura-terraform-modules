# 🚀 WeAura Monitoring Stack - Terraform Guide for Clients

**Version**: 1.0.0  
**Date**: February 25, 2026  
**Module**: `monitoring-stack` v1.0.0

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Step 1: Configure Terraform Cloud](#step-1-configure-terraform-cloud)
4. [Step 2: Configure AWS Credentials](#step-2-configure-aws-credentials)
5. [Step 3: Create Terraform Configuration](#step-3-create-terraform-configuration)
6. [Step 4: Deploy Monitoring Stack](#step-4-deploy-monitoring-stack)
7. [Step 5: Verify Deployment](#step-5-verify-deployment)
8. [Step 6: Access Grafana](#step-6-access-grafana)
9. [Customization Options](#customization-options)
10. [Maintenance](#maintenance)
11. [Troubleshooting](#troubleshooting)
12. [Support](#support)

---

## Overview

The **WeAura Monitoring Stack** is a complete observability solution delivered as a Terraform module. It deploys:

- 📊 **Grafana** - Visualization and dashboarding
- 📝 **Loki** - Log aggregation
- 📈 **Mimir** - Long-term metrics storage
- 🔍 **Tempo** - Distributed tracing
- ⚡ **Prometheus** - Real-time metrics
- 🔥 **Pyroscope** - Continuous profiling

### Key Features

- ✅ **Fully Automated**: Creates S3 buckets, IAM roles, and Kubernetes resources
- ✅ **Secure**: Uses IRSA (IAM Roles for Service Accounts) for AWS access
- ✅ **Integrated**: Pre-configured Grafana datasources
- ✅ **Production-Ready**: High availability, persistent storage, and backup policies
- ✅ **Customizable**: Extensive configuration options for sizing, retention, and branding

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Your AWS Account                         │
│                                                              │
│  ┌────────────────┐         ┌──────────────────┐           │
│  │  EKS Cluster   │         │   AWS Resources   │           │
│  │                │         │                   │           │
│  │  ┌──────────┐  │         │  • S3 Buckets    │           │
│  │  │ Grafana  │  │◄────────┤  • IAM Roles     │           │
│  │  │ Loki     │  │         │  • Policies      │           │
│  │  │ Mimir    │  │         │                   │           │
│  │  │ Tempo    │  │         └──────────────────┘           │
│  │  │Prometheus│  │                                         │
│  │  │Pyroscope │  │         ┌──────────────────┐           │
│  │  └──────────┘  │         │ WeAura ECR       │           │
│  │                │         │ (Cross-Account)  │           │
│  └────────────────┘         └──────────────────┘           │
│         ▲                            ▲                      │
│         │                            │                      │
│         └────────────────┬───────────┘                      │
│                          │                                  │
│                   Terraform Module                          │
│            (app.terraform.io/weauratech)                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

Before you begin, ensure you have:

### Required Tools

- ✅ **Terraform** >= 1.3.0
  ```bash
  terraform version
  ```

- ✅ **AWS CLI** >= 2.0 (configured with credentials)
  ```bash
  aws --version
  aws sts get-caller-identity
  ```

- ✅ **kubectl** (configured for your EKS cluster)
  ```bash
  kubectl version --client
  kubectl cluster-info
  ```

### Required Access

- ✅ **Terraform Cloud token** (provided by WeAura)
- ✅ **AWS account** with EKS cluster
- ✅ **AWS permissions**:
  - IAM: Create roles and policies
  - S3: Create and manage buckets
  - EKS: Access to cluster
  - ECR: Pull images from WeAura registry (cross-account)

### Cluster Requirements

- Kubernetes version: **1.23+**
- Minimum nodes: **3** (for high availability)
- Node instance type: **t3.large** or larger recommended
- Storage class: **gp3** or equivalent for PVCs

---

## Step 1: Configure Terraform Cloud

### 1.1: Log into Terraform Cloud

You need a Terraform Cloud token provided by WeAura to access the `monitoring-stack` module.

```bash
# Interactive login (recommended)
terraform login app.terraform.io
```

When prompted, paste the token provided by WeAura.

### 1.2: Alternative - Manual Token Configuration

Create or edit `~/.terraform.d/credentials.tfrc.json`:

```json
{
  "credentials": {
    "app.terraform.io": {
      "token": "YOUR_WEAURA_PROVIDED_TOKEN"
    }
  }
}
```

### 1.3: Verify Access

```bash
# Test that Terraform can authenticate
terraform version
# Should show Terraform version without errors
```

---

## Step 2: Configure AWS Credentials

### 2.1: AWS CLI Profile

Ensure your AWS CLI is configured with credentials that have permissions to:
- Create IAM roles and policies
- Create S3 buckets
- Manage EKS resources

```bash
# Configure AWS profile (if not already done)
aws configure --profile your-profile

# Verify access
aws sts get-caller-identity --profile your-profile
```

### 2.2: EKS Cluster Access

Update your kubeconfig to access the EKS cluster:

```bash
aws eks update-kubeconfig \
  --name your-cluster-name \
  --region us-east-1 \
  --profile your-profile

# Verify access
kubectl get nodes
```

---

## Step 3: Create Terraform Configuration

### 3.1: Create Project Directory

```bash
mkdir weaura-monitoring
cd weaura-monitoring
```

### 3.2: Create `main.tf`

Create the main Terraform configuration file:

```hcl
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }
  }
}

# --------------------------------
# AWS Provider
# --------------------------------

provider "aws" {
  region  = var.region
  profile = var.aws_profile  # Optional: use specific AWS profile
}

# --------------------------------
# EKS Cluster Data Sources
# --------------------------------

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# --------------------------------
# Kubernetes Provider
# --------------------------------

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# --------------------------------
# Helm Provider
# --------------------------------

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# --------------------------------
# WeAura Monitoring Stack Module
# --------------------------------

module "monitoring_stack" {
  source  = "app.terraform.io/weauratech/monitoring-stack/aws"
  version = "1.0.0"

  # Cluster Configuration
  cluster_name = var.cluster_name
  region       = var.region

  # Namespace
  namespace        = "monitoring"
  create_namespace = true

  # Chart Configuration (WeAura ECR)
  chart_repository = "oci://950242546328.dkr.ecr.us-east-2.amazonaws.com/weaura-vendorized/charts"
  chart_version    = "0.1.0"

  # S3 Storage (automatically created)
  create_s3_buckets = true
  s3_bucket_prefix  = var.s3_bucket_prefix

  # Grafana Configuration
  grafana = {
    enabled             = true
    admin_password      = var.grafana_admin_password
    ingress_enabled     = var.grafana_ingress_enabled
    ingress_host        = var.grafana_ingress_host
    storage_size        = "20Gi"
    persistence_enabled = true
  }

  # Loki (Logs)
  loki = {
    enabled      = true
    storage_size = "50Gi"
    retention    = "7d"
  }

  # Mimir (Long-term Metrics)
  mimir = {
    enabled      = true
    storage_size = "100Gi"
    retention    = "30d"
  }

  # Tempo (Distributed Tracing)
  tempo = {
    enabled      = true
    storage_size = "50Gi"
    retention    = "7d"
  }

  # Prometheus (Real-time Metrics)
  prometheus = {
    enabled      = true
    storage_size = "50Gi"
    retention    = "15d"
  }

  # Pyroscope (Continuous Profiling)
  pyroscope = {
    enabled      = true
    storage_size = "30Gi"
    retention    = "7d"
  }

  # Grafana Branding (Optional)
  grafana_branding = {
    app_title     = "${var.company_name} - Observability"
    app_name      = "${var.company_name} Grafana"
    login_title   = "Welcome to ${var.company_name} Monitoring"
    primary_color = var.grafana_primary_color
  }

  # AWS Resource Tags
  tags = {
    Project     = "Observability"
    ManagedBy   = "Terraform"
    Environment = var.environment
    Owner       = var.owner
  }
}
```

### 3.3: Create `variables.tf`

```hcl
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "s3_bucket_prefix" {
  description = "Unique prefix for S3 buckets (must be globally unique)"
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "grafana_ingress_enabled" {
  description = "Enable Grafana ingress"
  type        = bool
  default     = false
}

variable "grafana_ingress_host" {
  description = "Grafana ingress hostname"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (production, staging, etc.)"
  type        = string
  default     = "production"
}

variable "owner" {
  description = "Team or person responsible for this stack"
  type        = string
  default     = "DevOps Team"
}

variable "company_name" {
  description = "Company name for branding"
  type        = string
  default     = "My Company"
}

variable "grafana_primary_color" {
  description = "Grafana primary theme color (hex)"
  type        = string
  default     = "#0066CC"
}
```

### 3.4: Create `terraform.tfvars`

**⚠️ IMPORTANT**: Add this file to `.gitignore` - it contains sensitive data!

```hcl
# AWS Configuration
region       = "us-east-1"
aws_profile  = "default"  # or your AWS profile name
cluster_name = "your-eks-cluster-name"

# S3 Configuration
# Must be globally unique! Suggestion: company-name-monitoring
s3_bucket_prefix = "mycompany-monitoring"

# Grafana Configuration
grafana_admin_password   = "ChangeThisToASecurePassword123!"
grafana_ingress_enabled  = false  # Set to true if you have ingress controller
grafana_ingress_host     = ""     # e.g., "grafana.mycompany.com"

# Metadata
environment      = "production"
owner            = "DevOps Team"
company_name     = "My Company"
grafana_primary_color = "#0066CC"
```

### 3.5: Create `outputs.tf`

```hcl
output "grafana_url" {
  description = "Grafana service URL (port-forward required if no ingress)"
  value       = module.monitoring_stack.grafana_service_name
}

output "namespace" {
  description = "Kubernetes namespace"
  value       = module.monitoring_stack.namespace
}

output "s3_buckets" {
  description = "Created S3 bucket names"
  value       = module.monitoring_stack.s3_buckets
}

output "iam_roles" {
  description = "Created IAM role ARNs"
  value       = module.monitoring_stack.iam_roles
}
```

### 3.6: Create `.gitignore`

```
# Terraform
.terraform/
*.tfstate
*.tfstate.*
.terraform.lock.hcl
crash.log

# Sensitive files
terraform.tfvars
*.auto.tfvars
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```

---

## Step 4: Deploy Monitoring Stack

### 4.1: Initialize Terraform

```bash
# Download providers and modules
terraform init
```

**Expected output**:
```
Initializing modules...
Downloading app.terraform.io/weauratech/monitoring-stack/aws 1.0.0...

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching ">= 5.0"...
- Finding hashicorp/kubernetes versions matching ">= 2.20"...
- Finding hashicorp/helm versions matching ">= 2.9"...

Terraform has been successfully initialized!
```

### 4.2: Validate Configuration

```bash
# Validate syntax and configuration
terraform validate
```

### 4.3: Plan Deployment

```bash
# See what will be created
terraform plan
```

**Review the plan carefully**. Terraform will show:
- 4 S3 buckets to be created
- 4 IAM roles to be created
- Multiple IAM policies
- Kubernetes namespace
- Helm release (umbrella chart)
- Service accounts with IRSA annotations

### 4.4: Apply Configuration

```bash
# Deploy the stack
terraform apply
```

Type `yes` when prompted.

**Deployment time**: ~5-10 minutes

---

## Step 5: Verify Deployment

### 5.1: Check Terraform Outputs

```bash
terraform output
```

**Example output**:
```
grafana_url = "weaura-monitoring-grafana"
namespace = "monitoring"
s3_buckets = {
  "loki" = "mycompany-monitoring-loki-abc123"
  "mimir" = "mycompany-monitoring-mimir-abc123"
  "pyroscope" = "mycompany-monitoring-pyroscope-abc123"
  "tempo" = "mycompany-monitoring-tempo-abc123"
}
iam_roles = {
  "loki" = "arn:aws:iam::123456789:role/monitoring-loki"
  "mimir" = "arn:aws:iam::123456789:role/monitoring-mimir"
  ...
}
```

### 5.2: Check Kubernetes Resources

```bash
# Check pods
kubectl get pods -n monitoring

# All pods should be Running (may take 2-3 minutes)
NAME                                      READY   STATUS    RESTARTS   AGE
weaura-monitoring-grafana-0               1/1     Running   0          5m
weaura-monitoring-loki-0                  1/1     Running   0          5m
weaura-monitoring-mimir-0                 1/1     Running   0          5m
weaura-monitoring-tempo-0                 1/1     Running   0          5m
weaura-monitoring-prometheus-0            1/1     Running   0          5m
weaura-monitoring-pyroscope-0             1/1     Running   0          5m
```

### 5.3: Check Persistent Volumes

```bash
# Check PVCs
kubectl get pvc -n monitoring

# All should be Bound
NAME                          STATUS   VOLUME    CAPACITY   STORAGECLASS
grafana-storage-grafana-0     Bound    pvc-...   20Gi       gp3
loki-storage-loki-0           Bound    pvc-...   50Gi       gp3
...
```

### 5.4: Check S3 Buckets

```bash
# List created buckets
aws s3 ls | grep monitoring

# Test access to one bucket
aws s3 ls s3://mycompany-monitoring-loki/
```

### 5.5: Check IAM Roles

```bash
# List IAM roles
aws iam list-roles | grep monitoring

# Describe a role
aws iam get-role --role-name monitoring-loki
```

---

## Step 6: Access Grafana

### 6.1: Port Forward (No Ingress)

If you don't have an ingress controller:

```bash
# Forward Grafana service to localhost
kubectl port-forward -n monitoring svc/weaura-monitoring-grafana 3000:80
```

Open browser: http://localhost:3000

### 6.2: Ingress (If Enabled)

If you enabled ingress in `terraform.tfvars`:

```bash
# Get ingress URL
kubectl get ingress -n monitoring
```

Open browser: https://your-grafana-domain.com

### 6.3: Login to Grafana

- **Username**: `admin`
- **Password**: (the value you set in `grafana_admin_password`)

### 6.4: Verify Datasources

1. Navigate to **Connections** → **Data Sources**
2. Verify all datasources are present and working:
   - ✅ Prometheus
   - ✅ Mimir
   - ✅ Loki
   - ✅ Tempo
   - ✅ Pyroscope

3. Click "Test" on each datasource - all should show "✅ Data source is working"

---

## Customization Options

### Sizing Presets

Adjust storage and retention based on your needs:

```hcl
# Small (default)
loki = {
  storage_size = "50Gi"
  retention    = "7d"
}

# Medium
loki = {
  storage_size = "200Gi"
  retention    = "14d"
}

# Large
loki = {
  storage_size = "500Gi"
  retention    = "30d"
}
```

### Disable Components

To disable a component you don't need:

```hcl
pyroscope = {
  enabled = false
}
```

### Custom Values

Pass additional Helm values:

```hcl
module "monitoring_stack" {
  # ... other config ...

  values_override = {
    grafana = {
      replicas = 2  # High availability
      resources = {
        requests = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    }
  }
}
```

### Ingress Configuration

Enable ingress with TLS:

```hcl
grafana = {
  enabled         = true
  ingress_enabled = true
  ingress_host    = "grafana.mycompany.com"
  ingress_class   = "nginx"
  ingress_tls     = true
  ingress_tls_secret = "grafana-tls"
}
```

---

## Maintenance

### Update Stack

To update the monitoring stack to a newer version:

```hcl
# In main.tf, update version
module "monitoring_stack" {
  source  = "app.terraform.io/weauratech/monitoring-stack/aws"
  version = "1.1.0"  # Update this
  # ...
}
```

Then:

```bash
terraform init -upgrade
terraform plan
terraform apply
```

### Backup and Restore

**S3 Buckets are persistent**. Data is stored in S3 and will survive pod restarts.

To backup Grafana dashboards:

```bash
# Export dashboards via Grafana API
curl -u admin:password http://localhost:3000/api/search?type=dash-db
```

### Scaling

Scale components by updating resources:

```hcl
prometheus = {
  enabled      = true
  storage_size = "200Gi"  # Increase storage
  retention    = "30d"    # Increase retention
}
```

Then `terraform apply`.

---

## Troubleshooting

### Issue: "Module not found"

**Cause**: Terraform Cloud authentication failed.

**Solution**:
```bash
# Re-authenticate
terraform login app.terraform.io

# Verify credentials file
cat ~/.terraform.d/credentials.tfrc.json

# Re-initialize
rm -rf .terraform .terraform.lock.hcl
terraform init
```

---

### Issue: "Error authenticating to ECR"

**Cause**: Cross-account ECR access not configured.

**Solution**:
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Test ECR access
aws ecr describe-repositories --region us-east-2 \
  --registry-id 950242546328

# Contact WeAura support if access denied
```

---

### Issue: Pods in CrashLoopBackOff

**Cause**: IAM permissions or S3 bucket access issue.

**Solution**:
```bash
# Check pod logs
kubectl logs -n monitoring <pod-name>

# Check service account annotations
kubectl get sa -n monitoring -o yaml

# Verify IAM role trust policy
aws iam get-role --role-name monitoring-loki
```

**Common causes**:
- IAM role trust policy missing OIDC provider
- S3 bucket permissions incorrect
- EKS cluster OIDC provider not configured

---

### Issue: Grafana datasources not working

**Cause**: Network connectivity or service discovery issue.

**Solution**:
```bash
# Check services
kubectl get svc -n monitoring

# Test connectivity from Grafana pod
kubectl exec -n monitoring weaura-monitoring-grafana-0 -- \
  curl http://weaura-monitoring-prometheus:9090/-/healthy

# Check Grafana logs
kubectl logs -n monitoring weaura-monitoring-grafana-0
```

---

### Issue: S3 bucket access denied

**Cause**: IAM policy or IRSA not configured correctly.

**Solution**:
```bash
# Verify IAM role policy
aws iam list-role-policies --role-name monitoring-loki

# Get policy document
aws iam get-role-policy \
  --role-name monitoring-loki \
  --policy-name loki-s3-access

# Verify service account annotation
kubectl get sa -n monitoring weaura-monitoring-loki -o yaml
# Should have: eks.amazonaws.com/role-arn annotation
```

---

### Issue: Terraform state drift

**Cause**: Manual changes made outside Terraform.

**Solution**:
```bash
# Check for drift
terraform plan

# Import manually created resources
terraform import module.monitoring_stack.aws_s3_bucket.loki mycompany-monitoring-loki-abc123

# Or reconcile by re-applying
terraform apply -refresh-only
```

---

## Support

### Documentation

- **Module README**: https://registry.terraform.io/modules/weauratech/monitoring-stack/aws
- **Helm Chart Guide**: (provided separately)
- **Architecture Diagrams**: (provided separately)

### Contact

- **Technical Support**: platform@weaura.io
- **Slack Channel**: #weaura-monitoring-support (if applicable)
- **Emergency**: (contact provided separately)

### Reporting Issues

When reporting issues, please include:

1. Terraform version: `terraform version`
2. Module version: (from `main.tf`)
3. Error messages: (full output)
4. Pod logs: `kubectl logs -n monitoring <pod-name>`
5. Terraform plan output: (if deployment failed)

---

## Appendix: Complete Example

**Minimal working example** (`terraform.tfvars`):

```hcl
cluster_name         = "my-eks-cluster"
region               = "us-east-1"
s3_bucket_prefix     = "acme-corp-monitoring"
grafana_admin_password = "SecurePassword123!"
```

**Production example** with all options:

```hcl
# AWS
region       = "us-east-1"
cluster_name = "production-eks"

# S3
s3_bucket_prefix = "acme-corp-prod-monitoring"

# Grafana
grafana_admin_password  = "VerySecurePassword123!"
grafana_ingress_enabled = true
grafana_ingress_host    = "grafana.acme-corp.com"

# Sizing (Large)
loki_storage    = "500Gi"
loki_retention  = "30d"
mimir_storage   = "1Ti"
mimir_retention = "90d"

# Branding
company_name          = "ACME Corporation"
grafana_primary_color = "#FF6600"

# Tags
environment = "production"
owner       = "Platform Team"
```

---

**End of Guide** 🎉

For additional help, contact WeAura support at platform@weaura.io
