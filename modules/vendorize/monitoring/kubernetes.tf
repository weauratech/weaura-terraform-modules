# ============================================================
# Kubernetes Resources
# ============================================================

# --------------------------------
# Namespace
# --------------------------------

resource "kubernetes_namespace" "monitoring" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace

    labels = {
      name        = var.namespace
      managed-by  = "terraform"
      environment = lookup(var.tags, "Environment", "unknown")
    }
  }
}

# --------------------------------
# Service Accounts with IRSA
# --------------------------------

# Loki ServiceAccount
resource "kubernetes_service_account" "loki" {
  count = var.loki.enabled && var.cloud_provider == "aws" ? 1 : 0

  metadata {
    name      = "loki"
    namespace = var.namespace

    annotations = local.effective_iam_mode == "irsa" ? {
      "eks.amazonaws.com/role-arn" = aws_iam_role.monitoring[0].arn
    } : {}
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# Mimir ServiceAccount
resource "kubernetes_service_account" "mimir" {
  count = var.mimir.enabled && var.cloud_provider == "aws" ? 1 : 0

  metadata {
    name      = "mimir"
    namespace = var.namespace

    annotations = local.effective_iam_mode == "irsa" ? {
      "eks.amazonaws.com/role-arn" = aws_iam_role.monitoring[0].arn
    } : {}
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# Tempo ServiceAccount
resource "kubernetes_service_account" "tempo" {
  count = var.tempo.enabled && var.cloud_provider == "aws" ? 1 : 0

  metadata {
    name      = "tempo"
    namespace = var.namespace

    annotations = local.effective_iam_mode == "irsa" ? {
      "eks.amazonaws.com/role-arn" = aws_iam_role.monitoring[0].arn
    } : {}
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# Pyroscope ServiceAccount
resource "kubernetes_service_account" "pyroscope" {
  count = var.pyroscope.enabled && var.cloud_provider == "aws" ? 1 : 0

  metadata {
    name      = "pyroscope"
    namespace = var.namespace

    annotations = local.effective_iam_mode == "irsa" ? {
      "eks.amazonaws.com/role-arn" = aws_iam_role.monitoring[0].arn
    } : {}
  }

  depends_on = [kubernetes_namespace.monitoring]
}
