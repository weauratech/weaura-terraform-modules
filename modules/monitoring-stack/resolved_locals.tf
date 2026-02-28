# ============================================================
# Resolved Local Values
# ============================================================
# Consolidates variables and secrets
# ============================================================

locals {
  # Grafana admin password resolution
  grafana_admin_password_resolved = coalesce(
    local.aws_grafana_admin_password,
    var.grafana_admin_password
  )

  # Alerting webhooks resolution
  alerting_webhooks = local.is_slack ? local.aws_slack_webhooks : {}
}
