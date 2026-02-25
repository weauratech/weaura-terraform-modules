# ============================================================
# Local Values
# ============================================================

locals {
  # --------------------------------
  # ECR Configuration
  # --------------------------------

  ecr_repository = "${var.ecr_account_id}.dkr.ecr.${var.ecr_region}.amazonaws.com/weaura-vendorized/charts"
  chart_oci_url  = "oci://${local.ecr_repository}"

  # --------------------------------
  # S3 Bucket Names (if using AWS)
  # --------------------------------

  s3_bucket_prefix = var.aws_config.s3_bucket_prefix != "" ? var.aws_config.s3_bucket_prefix : "${var.cluster_name}-monitoring"

  loki_s3_bucket      = "${local.s3_bucket_prefix}-loki"
  mimir_s3_bucket     = "${local.s3_bucket_prefix}-mimir"
  tempo_s3_bucket     = "${local.s3_bucket_prefix}-tempo"
  pyroscope_s3_bucket = "${local.s3_bucket_prefix}-pyroscope"

  # --------------------------------
  # Helm Values Construction
  # --------------------------------

  default_helm_values = {
    cloudProvider = var.cloud_provider

    # Grafana
    grafana = {
      enabled = var.grafana.enabled
      admin = {
        password = var.grafana.admin_password != "" ? var.grafana.admin_password : "admin"
      }
      ingress = {
        enabled = var.grafana.ingress_enabled
        hosts   = var.grafana.ingress_host != "" ? [var.grafana.ingress_host] : []
      }
      persistence = {
        enabled = var.grafana.persistence_enabled
        size    = var.grafana.storage_size
      }
    }

    # Loki
    loki = {
      enabled = var.loki.enabled
      storage = {
        size = var.loki.storage_size
      }
      retention = var.loki.retention
    }

    # Mimir
    mimir = {
      enabled = var.mimir.enabled
      storage = {
        size = var.mimir.storage_size
      }
      retention = var.mimir.retention
    }

    # Tempo
    tempo = {
      enabled = var.tempo.enabled
      storage = {
        size = var.tempo.storage_size
      }
      retention = var.tempo.retention
    }

    # Prometheus
    prometheus = {
      enabled = var.prometheus.enabled
      storage = {
        size = var.prometheus.storage_size
      }
      retention = var.prometheus.retention
    }

    # Pyroscope
    pyroscope = {
      enabled = var.pyroscope.enabled
      storage = {
        size = var.pyroscope.storage_size
      }
    }

    # AWS-specific configuration
    aws = var.cloud_provider == "aws" ? {
      region = var.region
      s3 = {
        loki = {
          bucket = local.loki_s3_bucket
          region = var.region
        }
        mimir = {
          bucket = local.mimir_s3_bucket
          region = var.region
        }
        tempo = {
          bucket = local.tempo_s3_bucket
          region = var.region
        }
        pyroscope = {
          bucket = local.pyroscope_s3_bucket
          region = var.region
        }
      }
      useIRSA = var.aws_config.use_irsa
    } : {}
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
      Module      = "monitoring-stack"
      Cluster     = var.cluster_name
      Environment = lookup(var.tags, "Environment", "unknown")
    }
  )
}
