# ============================================================
# TFLint Configuration
# ============================================================
# Configuration for TFLint - Terraform linter
# https://github.com/terraform-linters/tflint
# ============================================================

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# AWS-specific rules
plugin "aws" {
  enabled = true
  version = "0.32.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Azure-specific rules
plugin "azurerm" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# -----------------------------
# Rule Overrides
# -----------------------------

# Disable unused declarations check.
# Many variables and locals are intentionally kept for:
# - Future extensibility (dashboards provisioning, SSO providers)
# - Module consumer flexibility
# - Optional features not yet fully implemented
rule "terraform_unused_declarations" {
  enabled = false
}
