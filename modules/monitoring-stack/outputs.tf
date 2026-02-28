# ============================================================
# Outputs - Grafana OSS Module (Multi-Cloud)
# ============================================================
# Module outputs for integration with other systems.
# Provides cloud-agnostic and cloud-specific values.
# ============================================================

# ============================================================
# GRAFANA OUTPUTS
# ============================================================

output "grafana_url" {
  description = "Grafana URL"
  value       = var.enable_grafana ? "https://${var.grafana_domain}" : null
}

output "grafana_admin_user" {
  description = "Grafana admin username"
  value       = var.enable_grafana ? "admin" : null
}

output "grafana_namespace" {
  description = "Kubernetes namespace where Grafana is deployed"
  value       = var.enable_grafana ? var.monitoring_namespace : null
}

output "grafana_helm_release_name" {
  description = "Grafana Helm release name"
  value       = var.enable_grafana ? helm_release.monitoring.name : null
}

output "grafana_helm_release_version" {
  description = "Grafana Helm chart version deployed"
  value       = var.enable_grafana ? helm_release.monitoring.version : null
}

# ============================================================
# PROMETHEUS OUTPUTS
# ============================================================

output "prometheus_url" {
  description = "Prometheus internal service URL"
  value       = var.enable_prometheus ? local.datasource_urls.prometheus : null
}

output "prometheus_namespace" {
  description = "Kubernetes namespace where Prometheus is deployed"
  value       = var.enable_prometheus ? var.monitoring_namespace : null
}

output "prometheus_helm_release_name" {
  description = "Prometheus Helm release name"
  value       = var.enable_prometheus ? helm_release.monitoring.name : null
}

# ============================================================
# LOKI OUTPUTS
# ============================================================

output "loki_url" {
  description = "Loki internal service URL"
  value       = var.enable_loki ? local.datasource_urls.loki : null
}

output "loki_namespace" {
  description = "Kubernetes namespace where Loki is deployed"
  value       = var.enable_loki ? var.monitoring_namespace : null
}

output "loki_helm_release_name" {
  description = "Loki Helm release name"
  value       = var.enable_loki ? helm_release.monitoring.name : null
}

# ============================================================
# MIMIR OUTPUTS
# ============================================================

output "mimir_url" {
  description = "Mimir internal service URL (query endpoint)"
  value       = var.enable_mimir ? local.datasource_urls.mimir : null
}

output "mimir_push_url" {
  description = "Mimir push endpoint for remote write"
  value       = var.enable_mimir ? local.datasource_urls.mimir_push : null
}

output "mimir_namespace" {
  description = "Kubernetes namespace where Mimir is deployed"
  value       = var.enable_mimir ? var.monitoring_namespace : null
}

output "mimir_helm_release_name" {
  description = "Mimir Helm release name"
  value       = var.enable_mimir ? helm_release.monitoring.name : null
}

# ============================================================
# TEMPO OUTPUTS
# ============================================================

output "tempo_url" {
  description = "Tempo internal service URL"
  value       = var.enable_tempo ? local.datasource_urls.tempo : null
}

output "tempo_namespace" {
  description = "Kubernetes namespace where Tempo is deployed"
  value       = var.enable_tempo ? var.monitoring_namespace : null
}

output "tempo_helm_release_name" {
  description = "Tempo Helm release name"
  value       = var.enable_tempo ? helm_release.monitoring.name : null
}

# ============================================================
# PYROSCOPE OUTPUTS
# ============================================================

output "pyroscope_url" {
  description = "Pyroscope internal service URL"
  value       = var.enable_pyroscope ? local.datasource_urls.pyroscope : null
}

output "pyroscope_namespace" {
  description = "Kubernetes namespace where Pyroscope is deployed"
  value       = var.enable_pyroscope ? var.monitoring_namespace : null
}

output "pyroscope_helm_release_name" {
  description = "Pyroscope Helm release name"
  value       = var.enable_pyroscope ? helm_release.monitoring.name : null
}

# ============================================================
# DATASOURCE URLS (Consolidated)
# ============================================================

output "datasource_urls" {
  description = "Map of all datasource URLs for Grafana configuration"
  value = {
    prometheus = var.enable_prometheus ? local.datasource_urls.prometheus : null
    mimir      = var.enable_mimir ? local.datasource_urls.mimir : null
    mimir_push = var.enable_mimir ? local.datasource_urls.mimir_push : null
    loki       = var.enable_loki ? local.datasource_urls.loki : null
    tempo      = var.enable_tempo ? local.datasource_urls.tempo : null
    pyroscope  = var.enable_pyroscope ? local.datasource_urls.pyroscope : null
  }
}

# ============================================================
# KUBERNETES OUTPUTS
# ============================================================

output "namespaces" {
  description = "Monitoring namespace (all components share a single namespace)"
  value = {
    monitoring = var.monitoring_namespace
    grafana    = var.enable_grafana ? var.monitoring_namespace : null
    prometheus = var.enable_prometheus ? var.monitoring_namespace : null
    loki       = var.enable_loki ? var.monitoring_namespace : null
    mimir      = var.enable_mimir ? var.monitoring_namespace : null
    tempo      = var.enable_tempo ? var.monitoring_namespace : null
    pyroscope  = var.enable_pyroscope ? var.monitoring_namespace : null
  }
}

# ============================================================
# AWS OUTPUTS
# ============================================================

output "aws_s3_bucket_arns" {
  description = "ARNs of S3 buckets created (AWS only)"
  value = local.is_aws ? {
    loki_chunks  = var.enable_loki && var.create_storage ? aws_s3_bucket.this["loki_chunks"].arn : null
    loki_ruler   = var.enable_loki && var.create_storage ? aws_s3_bucket.this["loki_ruler"].arn : null
    mimir_blocks = var.enable_mimir && var.create_storage ? aws_s3_bucket.this["mimir_blocks"].arn : null
    mimir_ruler  = var.enable_mimir && var.create_storage ? aws_s3_bucket.this["mimir_ruler"].arn : null
    tempo        = var.enable_tempo && var.create_storage ? aws_s3_bucket.this["tempo"].arn : null
  } : null
}

output "aws_s3_bucket_names" {
  description = "Names of S3 buckets created (AWS only)"
  value = local.is_aws ? {
    loki_chunks  = var.enable_loki && var.create_storage ? aws_s3_bucket.this["loki_chunks"].id : null
    loki_ruler   = var.enable_loki && var.create_storage ? aws_s3_bucket.this["loki_ruler"].id : null
    mimir_blocks = var.enable_mimir && var.create_storage ? aws_s3_bucket.this["mimir_blocks"].id : null
    mimir_ruler  = var.enable_mimir && var.create_storage ? aws_s3_bucket.this["mimir_ruler"].id : null
    tempo        = var.enable_tempo && var.create_storage ? aws_s3_bucket.this["tempo"].id : null
  } : null
}

output "aws_iam_role_arns" {
  description = "ARNs of IAM roles for IRSA (AWS only)"
  value = local.is_aws ? {
    loki  = var.enable_loki ? aws_iam_role.irsa["loki"].arn : null
    mimir = var.enable_mimir ? aws_iam_role.irsa["mimir"].arn : null
    tempo = var.enable_tempo ? aws_iam_role.irsa["tempo"].arn : null
  } : null
}

# ============================================================
# CLOUD-AGNOSTIC STORAGE OUTPUTS
# ============================================================

output "storage_configuration" {
  description = "Cloud-agnostic storage configuration summary"
  value = {
    cloud_provider = var.cloud_provider
    storage_type   = "s3"
    region         = local.cloud_region

    # Storage identifiers (cloud-specific)
    aws = local.is_aws ? {
      bucket_names = {
        loki_chunks  = var.enable_loki && var.create_storage ? aws_s3_bucket.this["loki_chunks"].id : null
        loki_ruler   = var.enable_loki && var.create_storage ? aws_s3_bucket.this["loki_ruler"].id : null
        mimir_blocks = var.enable_mimir && var.create_storage ? aws_s3_bucket.this["mimir_blocks"].id : null
        mimir_ruler  = var.enable_mimir && var.create_storage ? aws_s3_bucket.this["mimir_ruler"].id : null
        tempo        = var.enable_tempo && var.create_storage ? aws_s3_bucket.this["tempo"].id : null
      }
    } : null
  }
}

# ============================================================
# GRAFANA FOLDER OUTPUTS
# ============================================================

output "grafana_folder_uids" {
  description = "UIDs of Grafana folders created"
  value = var.enable_grafana && var.enable_grafana_resources ? {
    infrastructure = grafana_folder.infrastructure[0].uid
    kubernetes     = grafana_folder.kubernetes[0].uid
    applications   = grafana_folder.applications[0].uid
    sre            = grafana_folder.sre[0].uid
    alerts         = grafana_folder.alerts[0].uid
    prometheus     = var.enable_prometheus ? grafana_folder.prometheus[0].uid : null
    loki           = var.enable_loki ? grafana_folder.loki[0].uid : null
    mimir          = var.enable_mimir ? grafana_folder.mimir[0].uid : null
    tempo          = var.enable_tempo ? grafana_folder.tempo[0].uid : null
    pyroscope      = var.enable_pyroscope ? grafana_folder.pyroscope[0].uid : null
    custom         = { for k, v in grafana_folder.custom : k => v.uid }
  } : null
}

# ============================================================
# ALERTING OUTPUTS
# ============================================================

output "alerting_configuration" {
  description = "Alerting configuration summary"
  value = {
    provider            = var.alerting_provider
    enabled             = var.alerting_provider != "none"
    default_contact     = var.alerting_provider != "none" ? local.default_contact_point : null
    notification_policy = var.enable_grafana && var.enable_grafana_resources && var.alerting_provider != "none" ? grafana_notification_policy.main[0].id : null
  }
}

# ============================================================
# HELM RELEASES STATUS
# ============================================================

output "helm_releases" {
  description = "Status of all Helm releases"
  value = {
    grafana = var.enable_grafana ? {
      name      = helm_release.monitoring.name
      namespace = helm_release.monitoring.namespace
      version   = helm_release.monitoring.version
      status    = helm_release.monitoring.status
    } : null

    prometheus = var.enable_prometheus ? {
      name      = helm_release.monitoring.name
      namespace = helm_release.monitoring.namespace
      version   = helm_release.monitoring.version
      status    = helm_release.monitoring.status
    } : null

    loki = var.enable_loki ? {
      name      = helm_release.monitoring.name
      namespace = helm_release.monitoring.namespace
      version   = helm_release.monitoring.version
      status    = helm_release.monitoring.status
    } : null

    mimir = var.enable_mimir ? {
      name      = helm_release.monitoring.name
      namespace = helm_release.monitoring.namespace
      version   = helm_release.monitoring.version
      status    = helm_release.monitoring.status
    } : null

    tempo = var.enable_tempo ? {
      name      = helm_release.monitoring.name
      namespace = helm_release.monitoring.namespace
      version   = helm_release.monitoring.version
      status    = helm_release.monitoring.status
    } : null

    pyroscope = var.enable_pyroscope ? {
      name      = helm_release.monitoring.name
      namespace = helm_release.monitoring.namespace
      version   = helm_release.monitoring.version
      status    = helm_release.monitoring.status
    } : null
  }
}

# ============================================================
# MODULE SUMMARY
# ============================================================

output "module_summary" {
  description = "Summary of module deployment"
  value = {
    cloud_provider = var.cloud_provider
    environment    = var.environment
    project        = var.project

    enabled_components = {
      grafana    = var.enable_grafana
      prometheus = var.enable_prometheus
      loki       = var.enable_loki
      mimir      = var.enable_mimir
      tempo      = var.enable_tempo
      pyroscope  = var.enable_pyroscope
    }

    features = {
      storage_created     = var.create_storage
      alerting_enabled    = var.alerting_provider != "none"
      alerting_provider   = var.alerting_provider
      resource_quotas     = var.enable_resource_quotas
      limit_ranges        = var.enable_limit_ranges
      network_policies    = var.enable_network_policies
      sso_enabled         = var.grafana_sso_enabled
      tls_external_secret = var.enable_tls_external_secret
    }

    grafana_url = var.enable_grafana ? "https://${var.grafana_domain}" : null
  }
}
