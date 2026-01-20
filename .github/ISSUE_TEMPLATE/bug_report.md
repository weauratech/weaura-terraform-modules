---
name: Bug Report
about: Report a bug or issue with a module
title: "[BUG] "
labels: bug
assignees: ""
---

## Module

Which module is affected?

- [ ] grafana-oss
- [ ] Other: \_\_\_

## Cloud Provider

- [ ] AWS
- [ ] Azure
- [ ] Both

## Describe the Bug

A clear and concise description of the bug.

## To Reproduce

Steps to reproduce the behavior:

1. Configure module with:

```hcl
module "example" {
  source = "..."

  # your configuration
}
```

2. Run `terraform apply`
3. See error

## Expected Behavior

What you expected to happen.

## Error Output

```
Paste any error messages here
```

## Environment

- Terraform version:
- Provider versions:
- Cloud: AWS / Azure
- Kubernetes version:

## Additional Context

Add any other context about the problem here.
