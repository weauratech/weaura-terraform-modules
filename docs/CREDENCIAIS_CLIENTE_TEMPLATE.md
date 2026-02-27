# 🔐 WeAura Monitoring Stack - Client Credentials

**Client**: `[CLIENT_NAME]`  
**Date**: `[DELIVERY_DATE]`  
**Environment**: `[production/staging/development]`  
**Valid Until**: `[EXPIRY_DATE]`

---

## 📋 Overview

This document contains the credentials and access information required to deploy the WeAura Monitoring Stack in your AWS account using Terraform.

**⚠️ SECURITY NOTICE**: This document contains sensitive credentials. Store securely and do not commit to version control.

---

## 🏢 GitHub Repository Access

### Organization Details

- **Organization**: `weauratech` (GitHub)
- **Repository URL**: `https://github.com/weauratech/weaura-terraform-modules`

### GitHub Personal Access Token

**Token**: `[REDACTED - See 1Password/Vault]`

**Token Name**: `client-[CLIENT_NAME]-monitoring-stack`  
**Created**: `[DATE]`  
**Expires**: `[EXPIRY_DATE]`  
**Permissions**: Read access to `weaura-terraform-modules` repository

### Usage

#### Option 1: Git Credential Helper (Recommended)

```bash
git config --global credential.helper store
```

When cloning or pulling, Git will prompt for username (use GitHub username) and password (use the token).

#### Option 2: Environment Variable

Set as environment variable:

```bash
export GITHUB_TOKEN="[PASTE_TOKEN_HERE]"
```


### Verification

```bash
# Test repository access
git ls-remote https://github.com/weauratech/weaura-terraform-modules.git
# Should show refs without authentication errors
```

---

## 📦 Harbor Registry Access

### Registry Information

- **Registry**: `registry.dev.weaura.ai`
- **Chart Repository**: `weaura-vendorized`
- **Harbor Location**: `dev.weaura.ai`
- **Harbor Project**: `weaura-vendorized`

### Chart Details

- **Chart Name**: `weaura-monitoring`
- **Current Version**: `0.1.0`
- **OCI URL**: `oci://registry.dev.weaura.ai/weaura-vendorized/weaura-monitoring:0.1.0`

### Authentication

**Automatic** (via Terraform module):
- The `monitoring-stack` Terraform module handles Harbor authentication automatically
- Uses Harbor robot accounts for secure, credential-based access
- No manual Harbor login required for Terraform usage

**Manual** (for direct Helm access - optional):
- Requires Harbor robot account configured by WeAura
- Contact WeAura support if you need direct Helm chart access

### Verification

```bash
# Verify Harbor access (requires robot account credentials)
docker login registry.dev.weaura.ai
# Username: robot$client-name
# Password: [provided by WeAura]

# Test chart pull
helm pull oci://registry.dev.weaura.ai/weaura-vendorized/weaura-monitoring --version 0.1.0

**Expected**: Chart pulled successfully (if Harbor credentials provided)
**If access denied**: Contact WeAura support for Harbor robot account credentials

---

## 📦 Module Information

### Harbor Charts Access

**Purpose**: Harbor chart repository access (managed by WeAura)

- **Source**: `git::https://github.com/weauratech/weaura-terraform-modules.git//modules/ecr-charts?ref=v1.0.0`
- **Current Version**: `1.0.0`
- **Documentation**: See CLIENT_GUIDE.md for Harbor registry usage

**Usage**:
```hcl
module "ecr_charts" {
  source  = "git::https://github.com/weauratech/weaura-terraform-modules.git//modules/ecr-charts?ref=v1.0.0"
  version = "1.0.0"
  
  # ... configuration ...
}
```

### Monitoring Stack Module

**Purpose**: Deploy complete WeAura monitoring stack (recommended - primary module)

- **Source**: `git::https://github.com/weauratech/weaura-terraform-modules.git//modules/monitoring-stack?ref=v1.0.0`
- **Current Version**: `1.0.0`
- **Documentation**: See CLIENT_GUIDE.md for complete deployment guide
- **Chart Version**: `weaura-monitoring` v0.1.0

**Usage**:
```hcl
module "monitoring_stack" {
  source  = "git::https://github.com/weauratech/weaura-terraform-modules.git//modules/monitoring-stack?ref=v1.0.0"
  version = "1.0.0"
  
  cluster_name         = "your-eks-cluster"
  region               = "us-east-1"
  namespace            = "monitoring"
  create_namespace     = true
  chart_repository     = "oci://registry.dev.weaura.ai/weaura-vendorized"
  chart_version        = "0.1.0"
  create_s3_buckets    = true
  s3_bucket_prefix     = "your-company-monitoring"
  
  grafana = {
    enabled        = true
    admin_password = "YourSecurePassword123!"
  }
  
  # ... additional configuration ...
}
```

**Module Components**:
- ✅ Grafana (visualization)
- ✅ Loki (logs)
- ✅ Mimir (long-term metrics)
- ✅ Tempo (traces)
- ✅ Prometheus (real-time metrics)
- ✅ Pyroscope (profiling)

---

## 🔧 Quick Start

### Step 1: Configure GitHub Access

```bash
# Configure GitHub Token
git config --global credential.helper store
# Paste token when prompted
```

### Step 2: Create Project Directory

```bash
mkdir weaura-monitoring
cd weaura-monitoring
```

### Step 3: Create Minimal Configuration

Create `main.tf`:

```hcl
terraform {
  required_version = ">= 1.3.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Change as needed
}

# EKS cluster data source
data "aws_eks_cluster" "cluster" {
  name = "your-cluster-name"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "your-cluster-name"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "monitoring_stack" {
  source  = "git::https://github.com/weauratech/weaura-terraform-modules.git//modules/monitoring-stack?ref=v1.0.0"
  version = "1.0.0"

  cluster_name = "your-cluster-name"
  region       = "us-east-1"
  namespace    = "monitoring"
  
  chart_repository  = "oci://registry.dev.weaura.ai/weaura-vendorized"
  chart_version     = "0.1.0"
  
  create_s3_buckets = true
  s3_bucket_prefix  = "yourcompany-monitoring"
  
  grafana = {
    enabled        = true
    admin_password = "ChangeThisPassword123!"
  }
}
```

### Step 4: Deploy

```bash
# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply
```

### Step 5: Access Grafana

```bash
# Port-forward to Grafana
kubectl port-forward -n monitoring svc/weaura-monitoring-grafana 3000:80

# Open browser: http://localhost:3000
# Username: admin
# Password: (value from grafana_admin_password)
```

---

## 📚 Documentation

### Provided Documentation

- ✅ **CLIENT_GUIDE.md** - Complete deployment guide
- ✅ **GUIA-DEPLOY-UMBRELLA.md** - Helm chart deployment guide (Portuguese)
- ✅ **Module README** - Terraform module documentation (Terraform Cloud registry)

### Online Resources

- **Terraform Cloud**: https://app.terraform.io
- **Module Registry**: https://registry.terraform.io/modules/weauratech/monitoring-stack/aws
- **Grafana Docs**: https://grafana.com/docs
- **AWS EKS**: https://docs.aws.amazon.com/eks

---

## 🆘 Support

### Technical Support

**Email**: `platform@weaura.io`  
**Response Time**: 24-48 hours (business days)  
**Emergency**: `[PHONE_NUMBER]` (critical issues only)

### Slack Channel (If Applicable)

**Workspace**: `[SLACK_WORKSPACE]`  
**Channel**: `#weaura-monitoring-support`

### Reporting Issues

When contacting support, please provide:

1. **Client name**: `[CLIENT_NAME]`
2. **Environment**: `[production/staging]`
3. **Error description**: Brief summary of the issue
4. **Terraform version**: Output of `terraform version`
5. **Error logs**: 
   - Terraform error output
   - Pod logs: `kubectl logs -n monitoring <pod-name>`
   - Events: `kubectl get events -n monitoring`
6. **Steps to reproduce**: What you were trying to do

---

## 📋 Onboarding Checklist

Use this checklist to ensure successful deployment:

### Pre-Deployment
- [ ] GitHub personal access token received and stored securely
- [ ] AWS credentials configured (`aws sts get-caller-identity` works)
- [ ] EKS cluster access verified (`kubectl get nodes` works)
- [ ] Reviewed CLIENT_GUIDE.md documentation
- [ ] Decided on S3 bucket prefix (must be globally unique)
- [ ] Generated secure Grafana admin password

### Deployment
- [ ] Created project directory
- [ ] Created `main.tf` with module configuration
- [ ] Created `terraform.tfvars` with variables
- [ ] Added `terraform.tfvars` to `.gitignore`
- [ ] Ran `terraform init` successfully
- [ ] Reviewed `terraform plan` output
- [ ] Ran `terraform apply` successfully

### Post-Deployment
- [ ] All pods running (`kubectl get pods -n monitoring`)
- [ ] PVCs bound (`kubectl get pvc -n monitoring`)
- [ ] S3 buckets created (`aws s3 ls | grep monitoring`)
- [ ] IAM roles created (`aws iam list-roles | grep monitoring`)
- [ ] Accessed Grafana successfully
- [ ] Verified all 5 datasources working in Grafana
- [ ] Tested sample queries in Grafana
- [ ] Documented Grafana URL and credentials internally
- [ ] Scheduled regular backup of Grafana dashboards

---

## 🔄 Maintenance

### Module Updates

WeAura will notify you of new module versions via email.

To update:

```hcl
# In main.tf, update version
module "monitoring_stack" {
  source  = "git::https://github.com/weauratech/weaura-terraform-modules.git//modules/monitoring-stack?ref=v1.0.0"
  version = "1.1.0"  # Update to new version
  # ...
}
```

Then:
```bash
terraform init -upgrade
terraform plan
terraform apply
```

### Token Rotation

GitHub personal access tokens expire on: `[EXPIRY_DATE]`

WeAura will provide a new token before expiration. To update:

```bash
# Re-login with new token
git config --global credential.helper store

# Or update credentials file manually
nano ~/.terraform.d/credentials.tfrc.json
```

---

## 🔒 Security Best Practices

### Credential Storage

- ✅ **DO**: Store in password manager (1Password, LastPass, Vault)
- ✅ **DO**: Encrypt credentials file (`terraform.tfvars`)
- ✅ **DO**: Add `terraform.tfvars` to `.gitignore`
- ❌ **DON'T**: Commit credentials to Git
- ❌ **DON'T**: Share credentials via email or Slack
- ❌ **DON'T**: Store credentials in plain text files

### Access Control

- Limit GitHub personal access token access to DevOps team only
- Use separate tokens for different environments (prod/staging)
- Rotate tokens regularly (at least every 90 days)
- Revoke tokens immediately when team members leave

### AWS Security

- Use IAM roles with least privilege principle
- Enable CloudTrail logging for S3 bucket access
- Enable S3 bucket encryption (handled by module)
- Enable S3 versioning for data protection
- Review IAM policies regularly

---

## 📞 Emergency Contacts

### Critical Issues

**Definition**: Production outage, data loss, security incident

**Contact**: `[EMERGENCY_PHONE]`  
**Available**: 24/7  
**Email**: `emergency@weaura.io`

### Non-Critical Issues

**Definition**: Questions, minor bugs, feature requests

**Contact**: `platform@weaura.io`  
**Response Time**: 24-48 hours (business days)

---

## 📝 Notes

### Custom Configuration

```
[Space for WeAura team to add client-specific notes, special configurations, or exceptions]
```

### Known Limitations

```
[Any known limitations or special considerations for this client's environment]
```

---

**Document Version**: 1.0  
**Last Updated**: `[DATE]`  
**Updated By**: `[WEAURA_TEAM_MEMBER]`

---

**End of Credentials Document** 🔐

**⚠️ REMINDER**: Store this document securely. Do not commit to version control or share via insecure channels.
