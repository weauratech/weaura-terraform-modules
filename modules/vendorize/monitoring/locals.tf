# ============================================================
# Local Values
# ============================================================

locals {
  # --------------------------------
  # --------------------------------
  # Harbor Configuration
  # --------------------------------

  chart_oci_url = "oci://${var.harbor_url}"

  # --------------------------------
  # S3 Bucket Names (if using AWS)
  # --------------------------------

  s3_bucket_prefix = var.aws_config.s3_bucket_prefix != "" ? var.aws_config.s3_bucket_prefix : "${var.cluster_name}-monitoring"

  loki_s3_bucket      = "${local.s3_bucket_prefix}-loki"
  mimir_s3_bucket     = "${local.s3_bucket_prefix}-mimir"
  tempo_s3_bucket     = "${local.s3_bucket_prefix}-tempo"
  pyroscope_s3_bucket = "${local.s3_bucket_prefix}-pyroscope"

  # --------------------------------
  # Sizing Presets
  # --------------------------------

  # Sizing presets matching chart v0.15.0
  sizing_presets = {
    small = {
      global = { sizing = { preset = "small" } }
    }
    medium = {
      global = { sizing = { preset = "medium" } }
    }
    large = {
      global = { sizing = { preset = "large" } }
    }
  }

  # Merge sizing preset into helm values (only if not custom)
  sizing_values = var.sizing_preset != "custom" ? local.sizing_presets[var.sizing_preset] : {}

  # --------------------------------
  # Helm Values Construction
  # --------------------------------

  default_helm_values = {
    global = merge(
      {
        sizing = {
          preset = var.sizing_preset
        }
        pdb = {
          enabled = var.pdb_enabled
        }
        alertRules = {
          enabled = var.alert_rules_enabled
          rules = {
            componentDown  = var.alert_rules.component_down
            diskPressure   = var.alert_rules.disk_pressure
            memoryPressure = var.alert_rules.memory_pressure
            highErrorRate  = var.alert_rules.high_error_rate
            replicationLag = var.alert_rules.replication_lag
          }
        }
        networkPolicy = {
          enabled           = var.network_policy_enabled
          allowedNamespaces = var.network_policy_allowed_namespaces
        }
        tls = {
          enabled = var.tls_enabled
          certManager = {
            enabled = var.tls_cert_manager.enabled
            issuerRef = {
              name = var.tls_cert_manager.issuer_ref.name
              kind = var.tls_cert_manager.issuer_ref.kind
            }
          }
        }
        alertmanager = {
          enabled = var.alertmanager_enabled
          receivers = {
            webhook = {
              enabled = var.alertmanager_receivers.webhook.enabled
              url     = var.alertmanager_receivers.webhook.url
            }
            email = {
              enabled   = var.alertmanager_receivers.email.enabled
              to        = var.alertmanager_receivers.email.to
              from      = var.alertmanager_receivers.email.from
              smarthost = var.alertmanager_receivers.email.smarthost
            }
          }
        }
        serviceMonitor = {
          autoEnable = var.service_monitor_auto_enable
        }
        memberlist = {
          clusterLabel = var.memberlist_cluster_label
        }
      },
      var.cloud_provider == "aws" ? {
        storage = {
          provider         = "aws"
          storageClassName = ""
          gp3 = {
            enabled = false
            name    = "gp3"
          }
          aws = {
            region = var.region
            buckets = {
              loki  = local.loki_s3_bucket
              mimir = local.mimir_s3_bucket
              tempo = local.tempo_s3_bucket
            }
          }
        }
      } : {}
    )

    grafana = {
      enabled = var.grafana.enabled
    }

    loki = merge(
      {
        enabled = var.loki.enabled
        retention = {
          period = var.loki.retention
        }
        serviceAccount = {
          create = var.cloud_provider != "aws"
          name   = "loki"
        }
      }
    )

    mimir = merge(
      {
        enabled = var.mimir.enabled
        retention = {
          period = var.mimir.retention
        }
        serviceAccount = {
          create = var.cloud_provider != "aws"
          name   = "mimir"
        }
      }
    )

    tempo = merge(
      {
        enabled = var.tempo.enabled
        retention = {
          period = var.tempo.retention
        }
        serviceAccount = {
          create = var.cloud_provider != "aws"
          name   = "tempo"
        }
      },
      var.cloud_provider == "aws" ? {
        storage = {
          trace = {
            backend = "s3"
            s3 = {
              bucket   = local.tempo_s3_bucket
              region   = var.region
              endpoint = "s3.${var.region}.amazonaws.com"
              insecure = false
            }
          }
        }
      } : {}
    )

    prometheus = {
      enabled = var.prometheus.enabled
    }

    pyroscope = {
      enabled = var.pyroscope.enabled
      serviceAccount = {
        create = var.cloud_provider != "aws"
        name   = "pyroscope"
      }
    }
  }

  # Merge default values with user-provided values
  helm_values = merge(local.default_helm_values, var.helm_values)

  # --------------------------------
  # Tags
  # --------------------------------

  common_tags = merge(
    var.tags,
    {
      ManagedBy   = "Terraform"
      Module      = "vendorize-monitoring"
      Cluster     = var.cluster_name
      Environment = lookup(var.tags, "Environment", "unknown")
    }
  )
}
