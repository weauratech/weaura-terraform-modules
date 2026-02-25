# Waves 5 & 6: Testing and Client Delivery

**Prerequisites**: Wave 4 manual Terraform Cloud setup must be complete  
**Status**: ⏳ BLOCKED - Waiting for Terraform Cloud configuration

---

## Wave 5: End-to-End Testing in aura-dev Cluster

**Objective**: Deploy and validate monitoring stack using Terraform modules

### Phase 1: Terraformize ECR Repository (30 min)

**Current State**: ECR repository created manually via AWS Console

**Goal**: Manage ECR via Terraform using `ecr-charts` module

```hcl
# File: infra/ecr-vendorized-charts/main.tf
module "vendorized_charts_ecr" {
  source = "app.terraform.io/weauratech/ecr-charts/aws"
  version = "1.0.0"

  repository_name = "weaura-vendorized/charts"
  
  lifecycle_policy_rules = [{
    description  = "Keep last 10 chart versions"
    rulePriority = 1
    selection = {
      tagStatus     = "tagged"
      tagPrefixList = ["weaura-monitoring", "grafana", "loki", "mimir", "tempo", "prometheus", "pyroscope"]
      countType     = "imageCountMoreThan"
      countNumber   = 10
    }
    action = {
      type = "expire"
    }
  }]

  repository_read_write_access_principals = []
  
  enable_immutable_tags = true
  enable_scan_on_push   = true

  tags = {
    Environment = "production"
    Project     = "weaura-monitoring"
    ManagedBy   = "terraform"
  }
}
```

**Actions**:
```bash
cd /Users/cayohollanda/Documents/Repos/WeAura/aura-platform-foundation
# OR create new directory: infra/ecr-vendorized-charts/

# 1. Create Terraform configuration
# 2. Import existing ECR repository
terraform import module.vendorized_charts_ecr.aws_ecr_repository.this weaura-vendorized/charts/weaura-monitoring

# 3. Apply to match state
terraform apply

# 4. Verify no changes
terraform plan  # Should show: No changes
```

**Verification**:
- [ ] ECR repository under Terraform management
- [ ] No drift between Terraform state and AWS
- [ ] Chart already published (weaura-monitoring:0.1.0) still accessible

---

### Phase 2: Test Monitoring Stack Deployment (1 hour)

**Target**: EKS cluster `aura-dev`, namespace `monitoring-test`

**Configuration**:

```hcl
# File: test/monitoring-stack-aura-dev/main.tf
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
  
  cloud {
    organization = "weauratech"
    workspaces {
      name = "monitoring-stack-test"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  profile = "weaura"
}

data "aws_eks_cluster" "aura_dev" {
  name = "aura-dev"
}

data "aws_eks_cluster_auth" "aura_dev" {
  name = "aura-dev"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.aura_dev.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.aura_dev.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.aura_dev.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.aura_dev.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.aura_dev.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.aura_dev.token
  }
}

module "monitoring_stack" {
  source  = "app.terraform.io/weauratech/monitoring-stack/aws"
  version = "1.0.0"

  cluster_name = "aura-dev"
  namespace    = "monitoring-test"
  
  chart_repository = "oci://950242546328.dkr.ecr.us-east-2.amazonaws.com/weaura-vendorized/charts"
  chart_version    = "0.1.0"

  # Storage Configuration
  create_s3_buckets = true
  s3_bucket_prefix  = "weaura-monitoring-test"
  
  grafana_config = {
    replicas = 1
    storage = {
      size = "10Gi"
    }
    ingress = {
      enabled = false
    }
  }

  loki_config = {
    replicas = 2
    retention_period = "168h"  # 7 days
  }

  mimir_config = {
    replicas = 2
    retention_period = "15d"
  }

  tempo_config = {
    replicas = 2
  }

  prometheus_config = {
    replicas = 2
    retention_period = "15d"
  }

  pyroscope_config = {
    replicas = 2
  }

  tags = {
    Environment = "test"
    Purpose     = "validation"
    ManagedBy   = "terraform"
  }
}

output "grafana_service" {
  value = module.monitoring_stack.grafana_service_name
}

output "s3_buckets" {
  value = module.monitoring_stack.s3_bucket_ids
}
```

**Execution Steps**:

```bash
# 1. Create test directory
mkdir -p /Users/cayohollanda/Documents/Repos/WeAura/weaura-terraform-modules/test/monitoring-stack-aura-dev
cd /Users/cayohollanda/Documents/Repos/WeAura/weaura-terraform-modules/test/monitoring-stack-aura-dev

# 2. Create configuration files
# (main.tf above)

# 3. Login to Terraform Cloud
terraform login app.terraform.io
# Use team token generated in Wave 4

# 4. Initialize
terraform init

# 5. Plan
terraform plan -out=tfplan

# 6. Review plan - should create:
#    - 6 S3 buckets (Loki, Mimir, Tempo, Pyroscope chunks/ruler, Grafana)
#    - IAM roles for service accounts (IRSA)
#    - IAM policies
#    - Kubernetes namespace
#    - Kubernetes service accounts
#    - Helm release (weaura-monitoring)

# 7. Apply
terraform apply tfplan

# 8. Wait for all pods to be ready (5-10 minutes)
kubectl get pods -n monitoring-test -w
```

**Validation Checklist**:

```bash
# 1. Check all pods running
kubectl get pods -n monitoring-test
# Expected: All pods in Running state, Ready 1/1 or 2/2

# 2. Verify services
kubectl get svc -n monitoring-test

# 3. Port-forward Grafana
kubectl port-forward -n monitoring-test svc/weaura-monitoring-grafana 3000:80

# 4. Access Grafana
open http://localhost:3000
# Login: admin / (get password from secret)
kubectl get secret -n monitoring-test weaura-monitoring-grafana -o jsonpath='{.data.admin-password}' | base64 -d

# 5. Verify datasources (auto-configured)
# Grafana UI > Configuration > Data Sources
# Expected: 5 datasources (Loki, Mimir, Tempo, Prometheus, Pyroscope)

# 6. Test queries
# Loki: {namespace="monitoring-test"}
# Mimir: up
# Tempo: (traces should be visible)
# Prometheus: up
# Pyroscope: (profiles should be visible)

# 7. Verify S3 buckets created
aws s3 ls | grep weaura-monitoring-test
# Expected: 6 buckets

# 8. Verify IAM roles created
aws iam list-roles | grep monitoring-test
# Expected: IRSA roles for Loki, Mimir, Tempo, Pyroscope, Grafana

# 9. Check Terraform state
terraform show

# 10. Verify no drift
terraform plan
# Expected: No changes. Your infrastructure matches the configuration.
```

**Success Criteria**:
- [ ] All 6 components deployed (Grafana, Loki, Mimir, Tempo, Prometheus, Pyroscope)
- [ ] All pods healthy and ready
- [ ] Grafana accessible via port-forward
- [ ] 5 datasources auto-configured in Grafana
- [ ] Test queries return results
- [ ] S3 buckets created and accessible
- [ ] IAM roles created with correct trust policies
- [ ] Terraform state matches infrastructure (no drift)

**Cleanup** (after validation):
```bash
# Destroy test deployment
terraform destroy -auto-approve

# Verify cleanup
kubectl get ns monitoring-test  # Should not exist
aws s3 ls | grep weaura-monitoring-test  # Should be empty (buckets deleted)
aws iam list-roles | grep monitoring-test  # Should be empty (roles deleted)
```

---

## Wave 6: Client Documentation and Credentials

**Objective**: Prepare comprehensive client onboarding package

### Deliverables

#### 1. Update Deployment Guides (30 min)

**File**: `weaura-vendorized-stack/GUIA-DEPLOY-UMBRELLA.md`

**Updates Needed**:
- ✅ Section 1: Keep Helm direct installation (for reference)
- ✅ Section 2: **ADD** - Terraform Cloud installation (preferred method)
- ✅ Section 3: Update ECR registry instructions
- ✅ Section 4: Add Terraform module configuration examples

**File**: `weaura-vendorized-stack/CHECKLIST-PRE-CLIENTE.md`

**Updates Needed**:
- ✅ Update checklist to include Terraform Cloud token distribution
- ✅ Add module version verification steps
- ✅ Update credentials section (Terraform Cloud + ECR)

#### 2. Create Terraform Client Guide (1 hour)

**File**: `weaura-terraform-modules/docs/CLIENT_GUIDE.md`

**Structure**:
```markdown
# WeAura Monitoring Stack - Terraform Guide for Clients

## Prerequisites
- Terraform >= 1.0
- AWS CLI configured
- EKS cluster access
- Terraform Cloud token (provided by WeAura)

## Step 1: Configure Terraform Cloud
[...]

## Step 2: Configure AWS Credentials
[...]

## Step 3: Deploy Monitoring Stack
[...]

## Step 4: Verify Deployment
[...]

## Step 5: Access Grafana
[...]

## Troubleshooting
[...]
```

#### 3. Create Credentials Template (15 min)

**File**: `weaura-terraform-modules/docs/CREDENCIAIS_CLIENTE_TEMPLATE.md`

```markdown
# WeAura Monitoring Stack - Client Credentials

**Client**: [CLIENT_NAME]  
**Date**: [DATE]  
**Environment**: [ENVIRONMENT]

## Terraform Cloud Access

**Organization**: weauratech  
**Team Token**: [REDACTED - See 1Password]  
**Token Expiry**: [DATE]

### Usage:
```bash
terraform login app.terraform.io
# Paste token when prompted
```

## AWS ECR Registry

**Registry**: 950242546328.dkr.ecr.us-east-2.amazonaws.com  
**Repository**: weaura-vendorized/charts  

### Chart Access:
- Via Terraform module: Automatic (IRSA handles authentication)
- Direct Helm pull: Requires cross-account IAM role

## Module Information

**ECR Charts Module**:
- Source: `app.terraform.io/weauratech/ecr-charts/aws`
- Version: `1.0.0`

**Monitoring Stack Module**:
- Source: `app.terraform.io/weauratech/monitoring-stack/aws`
- Version: `1.0.0`
- Chart: `weaura-monitoring` v0.1.0

## Support

**Technical Contact**: platform@weaura.io  
**Documentation**: [URL to internal docs]
```

#### 4. Client Onboarding Checklist (15 min)

**File**: `weaura-terraform-modules/docs/CLIENT_ONBOARDING_CHECKLIST.md`

```markdown
# Client Onboarding Checklist - WeAura Monitoring Stack

## Pre-Delivery
- [ ] Terraform Cloud team token generated
- [ ] Token stored in 1Password/Vault
- [ ] Client-specific credentials document prepared
- [ ] Example Terraform configuration created
- [ ] Internal testing completed (Wave 5)

## Delivery
- [ ] Send credentials via secure channel (1Password share)
- [ ] Share documentation (CLIENT_GUIDE.md)
- [ ] Schedule onboarding call
- [ ] Walk through deployment example

## Post-Delivery
- [ ] Verify client can access Terraform Cloud
- [ ] Verify client can download modules
- [ ] Assist with first deployment
- [ ] Verify monitoring stack operational
- [ ] Collect feedback
```

#### 5. Generate Actual Client Token (5 min)

**Manual Steps**:
1. Log into Terraform Cloud: https://app.terraform.io/app/weauratech
2. Settings > Teams > Create "Clients" team
3. Team Settings > Tokens > Generate new token
4. **Copy token immediately** (only shown once)
5. Store in 1Password vault: `WeAura Platform/Terraform Cloud/Client Team Token`
6. Document token metadata:
   - Created: [DATE]
   - Expiry: [DATE or "Never"]
   - Permissions: Read access to modules

#### 6. Final Verification (15 min)

**Checklist**:
- [ ] All documentation complete and reviewed
- [ ] Credentials template filled out
- [ ] Client token generated and stored securely
- [ ] Example configurations tested
- [ ] Internal wiki/knowledge base updated
- [ ] Ready for client delivery

---

## Timeline Summary

| Wave | Phase | Duration | Dependencies |
|------|-------|----------|--------------|
| 5 | Terraformize ECR | 30 min | TF Cloud setup |
| 5 | Test Deployment | 1 hour | ECR Terraformized |
| 5 | Validation | 30 min | Deployment complete |
| 5 | Cleanup | 10 min | Validation done |
| 6 | Update Guides | 30 min | Wave 5 complete |
| 6 | Create Client Guide | 1 hour | - |
| 6 | Credentials Template | 15 min | - |
| 6 | Onboarding Checklist | 15 min | - |
| 6 | Generate Token | 5 min | TF Cloud setup |
| 6 | Final Verification | 15 min | All docs complete |

**Total Estimated Time**: 4 hours 30 minutes

---

## Success Metrics

### Wave 5 Success:
- ✅ Monitoring stack deployed via Terraform
- ✅ All components healthy
- ✅ Datasources auto-configured
- ✅ Queries returning data
- ✅ Infrastructure matches code (no drift)
- ✅ Clean destruction (no orphaned resources)

### Wave 6 Success:
- ✅ Comprehensive client documentation
- ✅ Working example configurations
- ✅ Secure credential distribution process
- ✅ Client can deploy monitoring stack independently
- ✅ Client support process documented

---

## Notes

- **Wave 5 is blocked** until Terraform Cloud manual setup (Wave 4) is complete
- **Wave 6 can be started in parallel** with Wave 5 (documentation work)
- Testing should be done in `monitoring-test` namespace, not `monitoring` (avoid conflicts)
- Always verify cleanup after testing (no orphaned AWS resources)
- Client token should have **read-only** access to modules (security best practice)

---

## Contact

**Questions**: Cayô Holland (@cayohollanda)  
**Platform Team**: platform@weaura.io
