# Terraform Cloud Setup Guide

This guide walks through setting up Terraform Cloud for publishing the WeAura Terraform modules privately to clients.

## Overview

WeAura Terraform modules are distributed via **Terraform Cloud Private Registry**, providing:
- ✅ Authentication-based access control
- ✅ Automatic module publishing from GitHub tags
- ✅ Version management and discovery
- ✅ No-code distribution (clients use standard Terraform syntax)

## Architecture

```
GitHub Repository (weaura-terraform-modules)
    ↓ (VCS webhook on git tag)
Terraform Cloud Private Registry
    ↓ (authenticated API call)
Client Terraform Configuration
```

## Prerequisites

1. **Terraform Cloud Organization**: `weauratech` (or your organization name)
2. **GitHub Repository Access**: Admin access to `weauratech/weaura-terraform-modules`
3. **Terraform Cloud Plan**: Team or higher (for private modules)

## Step 1: Create Terraform Cloud Organization

### 1.1 Sign Up / Log In

Visit https://app.terraform.io and create an account or log in.

### 1.2 Create Organization

1. Click **"Create Organization"**
2. Name: `weauratech` (or your preferred name)
3. Email: `platform@weaura.io`
4. Select plan: **Team** (required for private modules)

## Step 2: Connect GitHub Repository

### 2.1 Configure VCS Provider

1. Go to **Settings > VCS Providers**
2. Click **"Connect a VCS Provider"**
3. Select **GitHub**
4. Choose **GitHub.com (OAuth)**
5. Authorize Terraform Cloud to access your GitHub organization
6. Grant access to `weauratech/weaura-terraform-modules` repository

### 2.2 Verify Connection

- Test the connection
- Ensure webhook is created in GitHub repository settings

## Step 3: Configure Module Registry

### 3.1 Add Modules to Registry

For each module (`ecr-charts`, `monitoring-stack`):

1. Navigate to **Registry > Modules**
2. Click **"+ Add Module"**
3. Select **"GitHub"** as the source
4. Choose repository: `weauratech/weaura-terraform-modules`
5. **Important**: For module path, use subdirectory format
   - For `ecr-charts`: Module path = `modules/ecr-charts`
   - For `monitoring-stack`: Module path = `modules/monitoring-stack`
6. Click **"Publish Module"**

### 3.2 Configure Module Settings

For each module:

1. Go to module settings
2. **Version Strategy**: Select **"Tags"**
3. **Tag Pattern**: `modules/{module-name}/v*` (e.g., `modules/ecr-charts/v*`)
4. Enable **"Auto-publish on new tags"**
5. Save settings

## Step 4: Module Tagging Strategy

### 4.1 Tag Format

Our release-please workflow creates tags in this format:
```
modules/{module-name}/v{version}
```

Examples:
- `modules/ecr-charts/v1.0.0`
- `modules/monitoring-stack/v1.0.0`
- `modules/ecr-charts/v1.1.0`

### 4.2 Automated Tagging

The repository uses **Release Please** GitHub Action to automate versioning:

1. Commit follows Conventional Commits format:
   ```
   feat(monitoring-stack): add new feature
   fix(ecr-charts): fix bug
   ```

2. Release Please creates PR with version bump

3. Merge PR → Release Please creates git tag

4. Terraform Cloud webhook triggers → Module published automatically

### 4.3 Manual Tagging (if needed)

```bash
# Tag a specific module version
git tag modules/ecr-charts/v1.0.0
git push origin modules/ecr-charts/v1.0.0

# Tag monitoring-stack
git tag modules/monitoring-stack/v1.0.0
git push origin modules/monitoring-stack/v1.0.0
```

## Step 5: Client Access Configuration

### 5.1 Create Team Token

For client access:

1. Go to **Settings > Teams**
2. Create team: `clients` or `external-users`
3. Add team to organization
4. Go to team settings
5. Generate **Team API Token**
6. **IMPORTANT**: Save this token securely (shown only once)
7. Share token with clients via secure channel (1Password, Vault)

### 5.2 Alternative: User Tokens

For individual client access:

1. Go to **User Settings > Tokens**
2. Create **Organization Token** for `weauratech`
3. Set expiration date (recommended: 90 days)
4. Share with client

### 5.3 Token Permissions

Ensure tokens have:
- ✅ Read access to private modules
- ❌ No write access to workspaces
- ❌ No admin access

## Step 6: Client Documentation

Provide clients with these instructions:

### 6.1 Configure Terraform CLI

**Option A: Environment Variable**
```bash
export TF_TOKEN_app_terraform_io="your-terraform-cloud-token"
```

**Option B: Credentials File**

Create `~/.terraform.d/credentials.tfrc.json`:
```json
{
  "credentials": {
    "app.terraform.io": {
      "token": "your-terraform-cloud-token"
    }
  }
}
```

### 6.2 Use Module in Terraform

```hcl
terraform {
  required_version = ">= 1.3.0"
}

# ECR Charts Module
module "ecr_charts" {
  source  = "app.terraform.io/weauratech/ecr-charts/aws"
  version = "1.0.0"
  
  charts = {
    weaura-monitoring = {
      name        = "weaura-monitoring"
      description = "WeAura monitoring stack"
    }
  }
}

# Monitoring Stack Module
module "monitoring_stack" {
  source  = "app.terraform.io/weauratech/monitoring-stack/aws"
  version = "1.0.0"
  
  cluster_name = "my-eks-cluster"
  region       = "us-east-1"
}
```

### 6.3 Initialize and Apply

```bash
terraform init    # Downloads modules from Terraform Cloud
terraform plan
terraform apply
```

## Step 7: Verify Setup

### 7.1 Check Module Registry

1. Go to **Registry > Modules** in Terraform Cloud
2. Verify modules appear:
   - `weauratech/ecr-charts/aws`
   - `weauratech/monitoring-stack/aws`
3. Check versions are published

### 7.2 Test Client Access

Create test Terraform configuration:

```hcl
# test.tf
module "test" {
  source  = "app.terraform.io/weauratech/monitoring-stack/aws"
  version = "1.0.0"
  
  cluster_name = "test"
  region       = "us-east-1"
}
```

Run:
```bash
export TF_TOKEN_app_terraform_io="test-token"
terraform init
```

Expected output:
```
Initializing modules...
Downloading app.terraform.io/weauratech/monitoring-stack/aws 1.0.0 for test...
```

## Step 8: Ongoing Maintenance

### 8.1 Publishing New Versions

1. Make changes to module in `modules/{module-name}/`
2. Commit using Conventional Commits:
   ```bash
   git commit -m "feat(monitoring-stack): add Azure support"
   ```
3. Push to `main` branch
4. Release Please creates PR with changelog
5. Review and merge PR
6. Release Please creates git tag
7. Terraform Cloud auto-publishes new version

### 8.2 Version Management

- **Patch** (1.0.x): Bug fixes, documentation updates
  ```bash
  git commit -m "fix(monitoring-stack): correct IAM policy"
  ```

- **Minor** (1.x.0): New features (backward compatible)
  ```bash
  git commit -m "feat(monitoring-stack): add CloudWatch alarms"
  ```

- **Major** (x.0.0): Breaking changes
  ```bash
  git commit -m "feat(monitoring-stack)!: change variable structure
  
  BREAKING CHANGE: aws_config is now a required variable"
  ```

### 8.3 Token Rotation

Rotate client tokens every 90 days:

1. Generate new team/organization token
2. Notify clients via email
3. Provide new token via secure channel
4. Revoke old token after grace period (7 days)

### 8.4 Monitoring Usage

Check Terraform Cloud analytics:
- **Registry > Modules > [module] > Analytics**
- View download counts
- Track version adoption

## Troubleshooting

### Issue: Module Not Found

**Error**: `Failed to install provider ... 404 Not Found`

**Solutions**:
1. Verify token is set: `echo $TF_TOKEN_app_terraform_io`
2. Check module source format: `app.terraform.io/ORG/MODULE/PROVIDER`
3. Confirm client has read access to private module
4. Test token with `terraform login app.terraform.io`

### Issue: Version Not Available

**Error**: `no versions of ... match the specified version constraint`

**Solutions**:
1. Check module exists in registry
2. Verify git tag was created: `git tag -l "modules/*/v*"`
3. Check Terraform Cloud webhook was triggered
4. View module versions in Terraform Cloud UI
5. Wait 1-2 minutes for webhook processing

### Issue: Webhook Not Triggering

**Solutions**:
1. Go to GitHub repo **Settings > Webhooks**
2. Find Terraform Cloud webhook
3. Check recent deliveries for errors
4. Re-deliver failed webhook
5. Verify VCS connection in Terraform Cloud

### Issue: Authentication Failed

**Error**: `401 Unauthorized`

**Solutions**:
1. Verify token is valid and not expired
2. Check token has correct permissions
3. Ensure user/team is member of organization
4. Re-generate token if needed

## Security Best Practices

### Token Management
- ✅ Use team tokens (not personal tokens) for clients
- ✅ Set expiration dates (90 days recommended)
- ✅ Rotate tokens regularly
- ✅ Revoke tokens when client relationship ends
- ✅ Use separate tokens per client for tracking

### Module Access
- ✅ Keep modules private (never public)
- ✅ Audit module access quarterly
- ✅ Use Terraform Cloud RBAC for internal teams
- ✅ Monitor download analytics for unusual activity

### Repository Security
- ✅ Protect `main` branch (require PR reviews)
- ✅ Use signed commits for releases
- ✅ Enable Dependabot for dependency updates
- ✅ Scan modules with `terraform validate` in CI

## Cost Considerations

### Terraform Cloud Pricing (as of 2024)

| Plan | Price/Month | Features |
|------|-------------|----------|
| Free | $0 | Public modules only |
| Team | $20/user | Private modules, RBAC, SSO |
| Business | Custom | Advanced features, SLA |

**For WeAura**: Team plan sufficient for private module distribution.

**Storage**: Modules are stored in GitHub (no additional cost).

## Support

### Internal Support
- Platform team: `platform@weaura.io`
- Terraform Cloud admin: Access via `weauratech` organization

### External Resources
- [Terraform Cloud Docs](https://developer.hashicorp.com/terraform/cloud-docs)
- [Private Registry](https://developer.hashicorp.com/terraform/cloud-docs/registry/publish-modules)
- [Module Publishing](https://developer.hashicorp.com/terraform/cloud-docs/registry/publish)

## Appendix: Module Source Formats

### Terraform Cloud Private Registry
```hcl
source = "app.terraform.io/ORGANIZATION/MODULE/PROVIDER"
```

Example:
```hcl
source = "app.terraform.io/weauratech/monitoring-stack/aws"
```

### Components Explained
- `app.terraform.io`: Terraform Cloud registry
- `weauratech`: Organization name
- `monitoring-stack`: Module name
- `aws`: Provider (inferred from module content)

### Version Constraints
```hcl
version = "1.0.0"       # Exact version
version = "~> 1.0"      # Minor version updates (1.0.x)
version = ">= 1.0.0"    # Minimum version
version = ">= 1.0, < 2.0"  # Version range
```

## Next Steps

After completing this setup:

1. ✅ Tag initial module versions
2. ✅ Verify modules appear in Terraform Cloud registry
3. ✅ Generate client access tokens
4. ✅ Create client onboarding documentation
5. ✅ Test end-to-end deployment in aura-dev cluster
6. ✅ Provide credentials to first client

---

**Document Version**: 1.0  
**Last Updated**: 2024-02  
**Maintained By**: Platform Team
