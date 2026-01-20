# ============================================================
# AWS Secrets Manager - Harbor Secrets
# ============================================================
# Creates secrets for Harbor in AWS Secrets Manager.
# These secrets are consumed via External Secrets Operator.
# Only created when cloud_provider = "aws" and create_secrets = true
# ============================================================

# -----------------------------
# Random Password Generation
# -----------------------------
resource "random_password" "harbor_admin" {
  count = local.is_aws && var.create_secrets && var.harbor_admin_password == "" ? 1 : 0

  length           = 32
  special          = true
  override_special = "!@#$%^&*()_+-="
}

resource "random_password" "harbor_secret_key" {
  count = local.is_aws && var.create_secrets ? 1 : 0

  length  = 16
  special = false
}

# -----------------------------
# Harbor Admin Password Secret
# -----------------------------
resource "aws_secretsmanager_secret" "harbor_admin" {
  count = local.is_aws && var.create_secrets ? 1 : 0

  name        = local.secrets_paths.admin_password
  description = "Harbor admin password for ${var.project} ${var.environment}"

  tags = merge(local.default_tags, {
    Name      = local.secrets_paths.admin_password
    Component = "harbor"
    Purpose   = "admin-password"
  })
}

resource "aws_secretsmanager_secret_version" "harbor_admin" {
  count = local.is_aws && var.create_secrets ? 1 : 0

  secret_id = aws_secretsmanager_secret.harbor_admin[0].id
  secret_string = jsonencode({
    password = var.harbor_admin_password != "" ? var.harbor_admin_password : random_password.harbor_admin[0].result
  })
}

# -----------------------------
# Harbor Secret Key
# -----------------------------
# Used for encryption of sensitive data in Harbor
resource "aws_secretsmanager_secret" "harbor_secret_key" {
  count = local.is_aws && var.create_secrets ? 1 : 0

  name        = local.secrets_paths.secret_key
  description = "Harbor encryption secret key for ${var.project} ${var.environment}"

  tags = merge(local.default_tags, {
    Name      = local.secrets_paths.secret_key
    Component = "harbor"
    Purpose   = "secret-key"
  })
}

resource "aws_secretsmanager_secret_version" "harbor_secret_key" {
  count = local.is_aws && var.create_secrets ? 1 : 0

  secret_id = aws_secretsmanager_secret.harbor_secret_key[0].id
  secret_string = jsonencode({
    secretKey = random_password.harbor_secret_key[0].result
  })
}

# -----------------------------
# External Secrets (via kubectl)
# -----------------------------
# Creates ExternalSecret resources to sync AWS Secrets Manager to Kubernetes Secrets

resource "kubectl_manifest" "harbor_admin_external_secret" {
  count = local.is_aws && var.create_secrets ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "harbor-admin-password"
      namespace = kubernetes_namespace.harbor.metadata[0].name
      labels    = local.common_labels
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = var.external_secrets_cluster_store_name
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "harbor-admin-password"
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "HARBOR_ADMIN_PASSWORD"
          remoteRef = {
            key      = local.secrets_paths.admin_password
            property = "password"
          }
        }
      ]
    }
  })

  depends_on = [
    kubernetes_namespace.harbor,
    aws_secretsmanager_secret_version.harbor_admin,
  ]
}

resource "kubectl_manifest" "harbor_secret_key_external_secret" {
  count = local.is_aws && var.create_secrets ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "harbor-secret-key"
      namespace = kubernetes_namespace.harbor.metadata[0].name
      labels    = local.common_labels
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = var.external_secrets_cluster_store_name
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "harbor-secret-key"
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "secretKey"
          remoteRef = {
            key      = local.secrets_paths.secret_key
            property = "secretKey"
          }
        }
      ]
    }
  })

  depends_on = [
    kubernetes_namespace.harbor,
    aws_secretsmanager_secret_version.harbor_secret_key,
  ]
}

# -----------------------------
# Local values for secret access
# -----------------------------
locals {
  # Retrieve admin password for Helm values
  harbor_admin_password_value = local.is_aws && var.create_secrets ? (
    var.harbor_admin_password != "" ? var.harbor_admin_password : random_password.harbor_admin[0].result
  ) : var.harbor_admin_password

  # Retrieve secret key for Helm values
  harbor_secret_key_value = local.is_aws && var.create_secrets ? random_password.harbor_secret_key[0].result : ""
}
