# ✅ Client Onboarding Checklist - WeAura Monitoring Stack

**Client Name**: `________________`  
**Environment**: `________________`  
**Onboarding Date**: `________________`  
**WeAura Contact**: `________________`

---

## 📋 Overview

This checklist ensures a smooth onboarding process for clients deploying the WeAura Monitoring Stack via GitHub.

**Estimated Time**: 2-3 hours (including deployment and verification)

---

## 🎯 Phase 1: Pre-Delivery Preparation

**Responsible**: WeAura Team  
**Timeline**: 1-2 days before client onboarding

### Infrastructure Setup

- [ ] **GitHub organization verified**
  - Organization: `weauratech`
  - Repository accessible
  - Versions: `ecr-charts` v1.0.0, `monitoring-stack` v1.0.0

- [ ] **Harbor chart published and tested**
  - Chart: `weaura-monitoring` v0.1.0
  - Registry: `registry.dev.weaura.ai`
  - Repository: `weaura-vendorized/charts/weaura-monitoring`
  - Digest verified: `sha256:2b9d3745...`

- [ ] **Harbor robot account configured** (if client needs direct Harbor registry access)
  - Client organization/username obtained: `________________`
  - Harbor robot account created for client
  - Robot account credentials stored securely (if applicable)

### Credentials Generation

- [ ] **GitHub personal access token generated**
  - Token name: `client-[CLIENT_NAME]-monitoring-stack`
  - Permissions: Read-only access to `weaura-terraform-modules` repository
  - Expiry date set: `________________` (recommended: 90 days)
  - Token stored securely in 1Password/Vault

- [ ] **Client credentials document prepared**
  - Template: `CREDENCIAIS_CLIENTE_TEMPLATE.md`
  - All placeholders filled with actual values
  - Client-specific notes added
  - Document reviewed by team lead

### Documentation Preparation

- [ ] **CLIENT_GUIDE.md reviewed and up-to-date**
  - Module versions correct (v1.0.0)
  - Chart version correct (v0.1.0)
  - All examples tested
  - Troubleshooting section complete

- [ ] **Example Terraform configuration prepared**
  - Client-specific values (cluster name, region, etc.)
  - Secure password placeholder
  - S3 bucket prefix suggestion (unique)
  - Tested in dev environment

### Internal Testing

- [ ] **End-to-end deployment tested** (Wave 5)
  - Deployed to `aura-dev` cluster
  - All 6 components healthy
  - Grafana datasources verified
  - S3 buckets created and accessible
  - IAM roles validated
  - Deployment cleaned up after test

- [ ] **Module version compatibility verified**
  - Terraform >= 1.3.0
  - AWS provider >= 5.0
  - Kubernetes provider >= 2.20
  - Helm provider >= 2.9

### Communication Preparation

- [ ] **Onboarding call scheduled**
  - Date/Time: `________________`
  - Duration: 90 minutes
  - Attendees confirmed:
    - WeAura: `________________`
    - Client: `________________`
  - Meeting link sent
  - Calendar invite sent with agenda

- [ ] **Slack channel created** (if applicable)
  - Channel: `#client-[CLIENT_NAME]-monitoring`
  - WeAura team members added
  - Client contacts invited

---

## 📦 Phase 2: Delivery

**Responsible**: WeAura Team + Client  
**Timeline**: Day 0 (onboarding call)

### Pre-Call Preparation (15 min before call)

- [ ] **Verify all materials ready**
  - Credentials document accessible
  - CLIENT_GUIDE.md ready to share
  - Example Terraform config ready
  - Screen sharing tested

- [ ] **Client access verification**
  - Slack channel access confirmed (if applicable)
  - 1Password share link prepared
  - GitHub repository access (if providing examples)

### Credentials Delivery (During Call - 15 min)

- [ ] **GitHub token delivered securely**
  - Method: 1Password secure share / Vault
  - ❌ NOT via email or Slack
  - ❌ NOT via screen share (token visible)
  - Client confirmed receipt: `Yes / No`

- [ ] **Credentials document shared**
  - File: `CREDENCIAIS_CLIENTE_[CLIENT_NAME].md`
  - Shared via: `________________`
  - Client saved locally: `Yes / No`

- [ ] **Security best practices explained**
  - Store in password manager
  - Add `terraform.tfvars` to `.gitignore`
  - Never commit credentials to Git
  - Token expiry date communicated: `________________`

### Documentation Delivery (During Call - 10 min)

- [ ] **CLIENT_GUIDE.md shared**
  - Method: `________________`
  - Client downloaded: `Yes / No`

- [ ] **Example Terraform configuration shared**
  - Repository link: `________________`
  - Or file sent via: `________________`

- [ ] **Additional resources provided**
  - GitHub repository links
  - Grafana documentation
  - AWS IRSA documentation

### Walkthrough (During Call - 45 min)

- [ ] **Prerequisites verification**
  - Terraform installed: `Yes / No` (version: `______`)
  - AWS CLI configured: `Yes / No`
  - kubectl access to EKS: `Yes / No`
  - EKS cluster details obtained:
    - Cluster name: `________________`
    - Region: `________________`
    - Kubernetes version: `________________`

- [ ] **GitHub authentication**
  - Walked through `git credential helper`
  - Token pasted successfully
  - Authentication verified

- [ ] **Terraform configuration setup**
  - Project directory created
  - `main.tf` created with module
  - `variables.tf` created
  - `terraform.tfvars` created with client-specific values:
    - Cluster name: `________________`
    - Region: `________________`
    - S3 bucket prefix: `________________` (verified unique)
    - Grafana password set (secure)

- [ ] **Deployment walkthrough**
  - `terraform init` executed successfully
  - Module downloaded from GitHub
  - `terraform validate` passed
  - `terraform plan` reviewed together
    - Expected resources confirmed (S3, IAM, K8s, Helm)
    - No unexpected changes
  - `terraform apply` executed
  - Deployment completed successfully
  - Time taken: `______` minutes

### Verification (During Call - 20 min)

- [ ] **Kubernetes resources verified**
  - All pods running:
    - `weaura-monitoring-grafana-0`: `Running / Not Running`
    - `weaura-monitoring-loki-0`: `Running / Not Running`
    - `weaura-monitoring-mimir-0`: `Running / Not Running`
    - `weaura-monitoring-tempo-0`: `Running / Not Running`
    - `weaura-monitoring-prometheus-0`: `Running / Not Running`
    - `weaura-monitoring-pyroscope-0`: `Running / Not Running`
  - All PVCs bound: `Yes / No`

- [ ] **AWS resources verified**
  - S3 buckets created: `Yes / No`
    - Count: `______` (expected: 4)
  - IAM roles created: `Yes / No`
    - Count: `______` (expected: 4)

- [ ] **Grafana access verified**
  - Port-forward established: `Yes / No`
  - Grafana UI accessible: `Yes / No`
  - Login successful: `Yes / No`

- [ ] **Datasources verified**
  - Prometheus: `Working / Not Working`
  - Mimir: `Working / Not Working`
  - Loki: `Working / Not Working`
  - Tempo: `Working / Not Working`
  - Pyroscope: `Working / Not Working`

- [ ] **Test queries executed**
  - Metrics query (Prometheus): `Success / Failed`
  - Logs query (Loki): `Success / Failed`
  - Traces query (Tempo): `Success / Failed` (if traces available)

---

## 🎓 Phase 3: Post-Delivery Follow-Up

**Responsible**: WeAura Team  
**Timeline**: 1-7 days after onboarding

### Immediate Follow-Up (Same Day)

- [ ] **Send follow-up email**
  - Subject: "WeAura Monitoring Stack - Onboarding Complete"
  - Contents:
    - Summary of what was deployed
    - Links to all documentation
    - Credentials reminder (stored securely)
    - Next steps
    - Support contact information
  - Sent to: `________________`
  - CC: `________________`

- [ ] **Update internal tracking**
  - CRM/Ticketing system updated
  - Deployment date recorded: `________________`
  - Client status: `Active / Needs Follow-Up`
  - Notes: `________________`

### 24-Hour Check-In

- [ ] **Slack/Email check-in sent**
  - Message: "How is the monitoring stack performing? Any questions?"
  - Response received: `Yes / No`
  - Issues reported: `Yes / No`
    - If yes, details: `________________`

- [ ] **Monitor for issues**
  - Check Slack channel for questions
  - No critical issues reported: `Yes / No`

### 1-Week Follow-Up

- [ ] **Follow-up call scheduled** (optional, if needed)
  - Scheduled for: `________________`
  - Topics to cover:
    - Performance review
    - Questions answered
    - Additional customization needs
    - Dashboard creation assistance

- [ ] **Usage verification**
  - Client actively using Grafana: `Yes / No`
  - Dashboards created: `Yes / No`
  - Data flowing correctly: `Yes / No`

- [ ] **Satisfaction survey sent**
  - Survey method: `________________`
  - Response received: `Yes / No`
  - Rating: `______/5`
  - Feedback: `________________`

### Documentation Updates

- [ ] **Client-specific documentation updated**
  - Any custom configurations documented
  - Known issues documented
  - Special requirements noted
  - Internal wiki updated

- [ ] **Lessons learned captured**
  - What went well: `________________`
  - What could be improved: `________________`
  - Updates needed to documentation: `________________`
  - Updates needed to module: `________________`

---

## 🚨 Phase 4: Issue Resolution (As Needed)

**Trigger**: Client reports issues during or after onboarding

### Issue Triage

- [ ] **Issue logged**
  - Date/Time: `________________`
  - Reported by: `________________`
  - Severity: `Critical / High / Medium / Low`
  - Description: `________________`

- [ ] **Initial diagnosis**
  - Category: `Authentication / Deployment / Configuration / Runtime`
  - Root cause identified: `Yes / No`
  - Estimated resolution time: `________________`

### Common Issues (Reference)

#### Issue: Module not found
- **Cause**: GitHub authentication failure
- **Resolution**: 
  - [ ] Verify token in `~/.terraform.d/credentials.tfrc.json`
  - [ ] Re-run `git credential helper`
  - [ ] Check token expiry date
  - [ ] Regenerate token if expired

#### Issue: Harbor authentication error
- **Cause**: Robot account credentials not configured
- **Resolution**:
  - [ ] Verify client Harbor robot account credentials
  - [ ] Check Harbor registry access policy
  - [ ] Verify robot account permissions
  - [ ] Contact WeAura infrastructure team

#### Issue: Pods in CrashLoopBackOff
- **Cause**: IAM permissions or S3 access
- **Resolution**:
  - [ ] Check pod logs: `kubectl logs -n monitoring <pod>`
  - [ ] Verify service account annotations
  - [ ] Check IAM role trust policy
  - [ ] Verify S3 bucket permissions

#### Issue: Grafana datasources not working
- **Cause**: Network connectivity
- **Resolution**:
  - [ ] Check service endpoints
  - [ ] Test connectivity from Grafana pod
  - [ ] Verify service names match datasource config
  - [ ] Check Grafana logs

### Resolution Tracking

- [ ] **Resolution implemented**
  - Solution: `________________`
  - Implemented by: `________________`
  - Verified by: `________________`
  - Time to resolve: `______` hours

- [ ] **Client notified**
  - Method: `Slack / Email / Call`
  - Client confirmed fix: `Yes / No`

- [ ] **Documentation updated** (if needed)
  - Known issue added to troubleshooting guide
  - Solution documented for future reference

---

## 📊 Phase 5: Success Metrics

**Review Date**: `________________`

### Deployment Success

- [ ] **Deployment completed**: `Yes / No`
- [ ] **Time to deploy**: `______` minutes (target: < 30 min)
- [ ] **All components healthy**: `Yes / No`
- [ ] **Zero critical issues**: `Yes / No`

### Client Satisfaction

- [ ] **Client feedback received**: `Yes / No`
- [ ] **Overall rating**: `______/5` (target: >= 4)
- [ ] **Would recommend**: `Yes / No / N/A`

### Documentation Quality

- [ ] **Client found docs helpful**: `Yes / No`
- [ ] **No documentation gaps reported**: `Yes / No`
- [ ] **Examples worked without modification**: `Yes / No`

### Support Quality

- [ ] **Response time met SLA**: `Yes / No` (target: < 24h)
- [ ] **Issue resolution time**: `______` hours (target: < 48h)
- [ ] **Client proactively using monitoring**: `Yes / No`

---

## 📝 Notes & Observations

### Client-Specific Notes

```
[Space for notes about client environment, special requirements, or observations]




```

### Issues Encountered

```
[Document any issues encountered during onboarding for future reference]




```

### Improvement Suggestions

```
[Suggestions for improving the onboarding process, documentation, or module]




```

---

## ✅ Sign-Off

### WeAura Team

**Onboarding Completed By**: `________________`  
**Date**: `________________`  
**Signature**: `________________`

**Reviewed By**: `________________` (Team Lead)  
**Date**: `________________`  
**Signature**: `________________`

### Client (Optional)

**Received Training**: `________________` (Name)  
**Date**: `________________`  
**Satisfaction**: `Satisfied / Needs Follow-Up`

---

## 📎 Attachments

- [ ] Credentials document (stored in 1Password/Vault)
- [ ] Example Terraform configuration (if custom)
- [ ] Client-specific notes
- [ ] Support ticket reference (if applicable): `________________`

---

**Checklist Version**: 1.0  
**Last Updated**: February 25, 2026  
**Owner**: WeAura Platform Team

---

**End of Onboarding Checklist** ✅
