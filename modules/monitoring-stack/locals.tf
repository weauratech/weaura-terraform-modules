# ============================================================
# Local Values - Grafana OSS Module (Multi-Cloud)
# ============================================================
# Centralized local values for multi-cloud configuration.
# Provides local variables for the module.
# ============================================================

locals {
  # ============================================================
  # CLOUD PROVIDER FLAGS
  # ============================================================
  is_aws = true

  # ============================================================
  # ALERTING PROVIDER FLAGS
  # ============================================================
  is_slack = var.alerting_provider == "slack"

  # ============================================================
  # NAMING
  # ============================================================
  name_prefix = var.name_prefix != "" ? var.name_prefix : var.project
  full_name   = "${local.name_prefix}-${var.environment}"

  # ============================================================
  # CLOUD-SPECIFIC CONFIGURATION
  # ============================================================

  # Region/Location
  cloud_region = var.aws_region

  # Cluster name
  cluster_name = var.eks_cluster_name

  # ============================================================
  # COMPONENT CONFIGURATION
  # ============================================================
  components = {
    grafana = {
      enabled     = var.enable_grafana
      namespace   = var.monitoring_namespace
      component   = "visualization"
      description = "Grafana OSS - Visualization and dashboarding"
    }
    prometheus = {
      enabled     = var.enable_prometheus
      namespace   = var.monitoring_namespace
      component   = "metrics"
      description = "Prometheus - Metrics collection"
    }
    loki = {
      enabled     = var.enable_loki
      namespace   = var.monitoring_namespace
      component   = "logs"
      description = "Loki - Log aggregation system"
    }
    mimir = {
      enabled     = var.enable_mimir
      namespace   = var.monitoring_namespace
      component   = "metrics-storage"
      description = "Mimir - Long-term metrics storage"
    }
    tempo = {
      enabled     = var.enable_tempo
      namespace   = var.monitoring_namespace
      component   = "tracing"
      description = "Tempo - Distributed tracing backend"
    }
    pyroscope = {
      enabled     = var.enable_pyroscope
      namespace   = var.monitoring_namespace
      component   = "profiling"
      description = "Pyroscope - Continuous profiling"
    }
  }

  # Filter enabled components
  enabled_components = { for k, v in local.components : k => v if v.enabled }

  # Namespace names for compatibility
  namespaces = { for k, v in local.components : k => v.namespace }

  # ============================================================
  # STORAGE CONFIGURATION
  # ============================================================

  # AWS S3 Bucket Configuration
  s3_buckets_config = {
    loki_chunks = {
      enabled     = var.enable_loki && local.is_aws
      bucket_name = var.s3_buckets.loki_chunks != "" ? var.s3_buckets.loki_chunks : "${local.full_name}-loki-chunks"
      component   = "loki"
      purpose     = "log-chunks"
      lifecycle_days = {
        transition_ia      = 30
        transition_glacier = 90
        expiration         = 365
      }
    }
    loki_ruler = {
      enabled        = var.enable_loki && local.is_aws
      bucket_name    = var.s3_buckets.loki_ruler != "" ? var.s3_buckets.loki_ruler : "${local.full_name}-loki-ruler"
      component      = "loki"
      purpose        = "ruler-storage"
      lifecycle_days = null
    }
    mimir_blocks = {
      enabled     = var.enable_mimir && local.is_aws
      bucket_name = var.s3_buckets.mimir_blocks != "" ? var.s3_buckets.mimir_blocks : "${local.full_name}-mimir-blocks"
      component   = "mimir"
      purpose     = "metrics-blocks"
      lifecycle_days = {
        transition_ia      = 30
        transition_glacier = 90
        expiration         = 730
      }
    }
    mimir_ruler = {
      enabled        = var.enable_mimir && local.is_aws
      bucket_name    = var.s3_buckets.mimir_ruler != "" ? var.s3_buckets.mimir_ruler : "${local.full_name}-mimir-ruler"
      component      = "mimir"
      purpose        = "ruler-storage"
      lifecycle_days = null
    }
    tempo = {
      enabled     = var.enable_tempo && local.is_aws
      bucket_name = var.s3_buckets.tempo != "" ? var.s3_buckets.tempo : "${local.full_name}-tempo"
      component   = "tempo"
      purpose     = "trace-storage"
      lifecycle_days = {
        transition_ia      = 30
        transition_glacier = 90
        expiration         = 180
      }
    }
  }

  enabled_s3_buckets        = { for k, v in local.s3_buckets_config : k => v if v.enabled }
  s3_buckets_with_lifecycle = { for k, v in local.enabled_s3_buckets : k => v if v.lifecycle_days != null }


  # ============================================================
  # IRSA / WORKLOAD IDENTITY CONFIGURATION
  # ============================================================

  # Components that need cloud storage access
  storage_components = {
    loki = {
      enabled     = var.enable_loki
      namespace   = var.monitoring_namespace
      bucket_keys = ["loki_chunks", "loki_ruler"]
    }
    mimir = {
      enabled     = var.enable_mimir
      namespace   = var.monitoring_namespace
      bucket_keys = ["mimir_blocks", "mimir_ruler"]
    }
    tempo = {
      enabled     = var.enable_tempo
      namespace   = var.monitoring_namespace
      bucket_keys = ["tempo"]
    }
  }

  enabled_storage_components = { for k, v in local.storage_components : k => v if v.enabled }

  # AWS IRSA role names
  irsa_role_names = { for k, v in local.storage_components : k => "${local.full_name}-${k}" }


  # AWS IRSA - filter by cloud provider
  enabled_irsa = { for k, v in local.enabled_storage_components : k => v if local.is_aws }


  # ============================================================
  # OIDC PROVIDER (AWS)
  # ============================================================
  oidc_provider_arn = var.eks_oidc_provider_arn
  oidc_provider_url = replace(var.eks_oidc_provider_url, "https://", "")

  # ============================================================
  # SECRETS PATHS
  secrets_paths = {
    slack_webhooks = var.aws_secrets_path_slack_webhooks
    grafana_admin  = var.aws_secrets_path_grafana_admin
  }

  # ============================================================
  # RESOURCE QUOTAS CONFIGURATION
  # ============================================================
  resource_quotas = {
    grafana = {
      requests_cpu    = "4"
      requests_memory = "8Gi"
      limits_cpu      = "8"
      limits_memory   = "16Gi"
      pvcs            = "5"
      services        = "10"
      secrets         = "20"
      configmaps      = "30"
    }
    prometheus = {
      requests_cpu    = "10"
      requests_memory = "20Gi"
      limits_cpu      = "20"
      limits_memory   = "40Gi"
      pvcs            = "10"
      services        = "20"
      secrets         = "30"
      configmaps      = "50"
    }
    loki = {
      requests_cpu    = "20"
      requests_memory = "40Gi"
      limits_cpu      = "40"
      limits_memory   = "80Gi"
      pvcs            = "15"
      services        = "15"
      secrets         = "20"
      configmaps      = "30"
    }
    mimir = {
      requests_cpu    = "30"
      requests_memory = "60Gi"
      limits_cpu      = "60"
      limits_memory   = "120Gi"
      pvcs            = "20"
      services        = "30"
      secrets         = "20"
      configmaps      = "30"
    }
    tempo = {
      requests_cpu    = "10"
      requests_memory = "16Gi"
      limits_cpu      = "20"
      limits_memory   = "32Gi"
      pvcs            = "10"
      services        = "15"
      secrets         = "15"
      configmaps      = "20"
    }
    pyroscope = {
      requests_cpu    = "8"
      requests_memory = "12Gi"
      limits_cpu      = "16"
      limits_memory   = "24Gi"
      pvcs            = "5"
      services        = "10"
      secrets         = "10"
      configmaps      = "15"
    }
  }

  # ============================================================
  # LIMIT RANGES CONFIGURATION
  # ============================================================
  limit_ranges = {
    grafana = {
      default_cpu            = "500m"
      default_memory         = "512Mi"
      default_request_cpu    = "100m"
      default_request_memory = "128Mi"
      min_cpu                = "10m"
      min_memory             = "16Mi"
      max_cpu                = "4"
      max_memory             = "8Gi"
    }
    prometheus = {
      default_cpu            = "500m"
      default_memory         = "512Mi"
      default_request_cpu    = "100m"
      default_request_memory = "128Mi"
      min_cpu                = "10m"
      min_memory             = "16Mi"
      max_cpu                = "8"
      max_memory             = "16Gi"
    }
    loki = {
      default_cpu            = "500m"
      default_memory         = "512Mi"
      default_request_cpu    = "100m"
      default_request_memory = "256Mi"
      min_cpu                = "10m"
      min_memory             = "16Mi"
      max_cpu                = "4"
      max_memory             = "16Gi"
    }
    mimir = {
      default_cpu            = "500m"
      default_memory         = "512Mi"
      default_request_cpu    = "100m"
      default_request_memory = "256Mi"
      min_cpu                = "10m"
      min_memory             = "16Mi"
      max_cpu                = "8"
      max_memory             = "16Gi"
    }
    tempo = {
      default_cpu            = "500m"
      default_memory         = "512Mi"
      default_request_cpu    = "100m"
      default_request_memory = "128Mi"
      min_cpu                = "10m"
      min_memory             = "16Mi"
      max_cpu                = "4"
      max_memory             = "8Gi"
    }
    pyroscope = {
      default_cpu            = "500m"
      default_memory         = "512Mi"
      default_request_cpu    = "100m"
      default_request_memory = "128Mi"
      min_cpu                = "10m"
      min_memory             = "16Mi"
      max_cpu                = "4"
      max_memory             = "8Gi"
    }
  }

  # ============================================================
  # NETWORK POLICY CONFIGURATION
  # ============================================================
  network_policies = {
    grafana = {
      allow_all_namespaces = false
      allowed_namespaces   = [var.monitoring_namespace, "ingress-nginx", "kube-system"]
    }
    prometheus = {
      allow_all_namespaces = true
      allowed_namespaces   = []
    }
    loki = {
      allow_all_namespaces = true
      allowed_namespaces   = []
    }
    mimir = {
      allow_all_namespaces = false
      allowed_namespaces   = [var.monitoring_namespace]
    }
    tempo = {
      allow_all_namespaces = true
      allowed_namespaces   = []
    }
    pyroscope = {
      allow_all_namespaces = true
      allowed_namespaces   = []
    }
  }

  # ============================================================
  # DATASOURCE URLs
  # ============================================================
  datasource_urls = {
    prometheus = "http://weaura-prometheus-prometheus.${local.namespaces.prometheus}.svc.cluster.local:9090"
    mimir      = "http://mimir-nginx.${local.namespaces.mimir}.svc.cluster.local:80/prometheus"
    mimir_push = "http://mimir-nginx.${local.namespaces.mimir}.svc.cluster.local:80/api/v1/push"
    loki       = var.loki_deployment_mode == "SingleBinary" ? "http://weaura-monitoring-loki.${local.namespaces.loki}.svc.cluster.local:3100" : "http://weaura-monitoring-loki-gateway.${local.namespaces.loki}.svc.cluster.local:80"
    tempo      = "http://tempo-query-frontend.${local.namespaces.tempo}.svc.cluster.local:3200"
    pyroscope  = "http://pyroscope.${local.namespaces.pyroscope}.svc.cluster.local:4040"
  }

  # ============================================================
  # ALERTING CHANNELS
  # ============================================================
  slack_channels = local.is_slack ? {
    general  = var.slack_channel_general
    critical = var.slack_channel_critical
    infra    = var.slack_channel_infrastructure
    app      = var.slack_channel_application
  } : {}

  # ============================================================
  # GRAFANA CONFIGURATION
  # ============================================================
  grafana_base_url = var.grafana_base_url != "" ? var.grafana_base_url : "https://${var.grafana_domain}"

  # ============================================================
  # COMMON LABELS (Kubernetes)
  # ============================================================
  common_labels = merge(var.labels, {
    "app.kubernetes.io/part-of"    = "observability-stack"
    "app.kubernetes.io/managed-by" = "terraform"
    "environment"                  = var.environment
    "cloud-provider"               = var.cloud_provider
  })

  # ============================================================
  # CLOUD TAGS
  # ============================================================
  default_tags = merge(var.tags, {
    Project       = var.project
    Environment   = var.environment
    ManagedBy     = "terraform"
    CloudProvider = var.cloud_provider
  })

  # ============================================================
  # HELM CHART REPOSITORIES
  # ============================================================
  helm_repositories = {
    grafana    = "https://grafana.github.io/helm-charts"
    prometheus = "https://prometheus-community.github.io/helm-charts"
  }

  # ============================================================
  # NODE SCHEDULING
  # ============================================================
  node_selector = var.global_node_selector
  tolerations   = var.global_tolerations

  # ============================================================
  # MONITORING UMBRELLA CHART - TEMPLATE VARIABLES
  # ============================================================
  # Consolidated template variables for umbrella chart deployment
  monitoring_template_vars = {
    # ============================================================
    # GLOBAL CONFIGURATION
    # ============================================================

    # Cloud provider
    cloud_provider = var.cloud_provider
    is_aws         = local.is_aws

    # Cloud region/location
    region = var.aws_region


    # Node scheduling (common)
    node_selector = local.node_selector
    tolerations   = local.tolerations
    storage_class = var.storage_class

    # ============================================================
    # GRAFANA
    # ============================================================

    grafana_domain         = var.grafana_domain
    grafana_admin_user     = var.grafana_admin_user
    grafana_admin_password = try(data.aws_secretsmanager_secret_version.grafana_admin[0].secret_string, var.grafana_admin_password)
    grafana_plugins        = var.grafana_plugins
    grafana_resources      = var.grafana_resources

    # Grafana persistence
    grafana_persistence_enabled = var.grafana_persistence_enabled
    grafana_persistence_size    = var.grafana_storage_size
    grafana_storage_size        = var.grafana_storage_size

    # Grafana ingress
    enable_ingress      = var.enable_ingress
    ingress_class       = var.ingress_class
    ingress_annotations = var.ingress_annotations
    enable_tls          = var.enable_tls
    tls_secret_name     = var.tls_secret_name
    cluster_issuer      = var.cluster_issuer

    # Grafana SSO
    grafana_sso_provider              = var.grafana_sso_provider
    grafana_sso_enabled               = var.grafana_sso_enabled
    grafana_sso_allowed_organizations = var.grafana_sso_allowed_organizations
    grafana_google_allowed_domains    = var.grafana_sso_allowed_domains
    oauth_client_id                   = var.grafana_sso_client_id
    oauth_client_secret               = var.grafana_sso_client_secret
    oauth_auth_url                    = var.grafana_oauth_auth_url
    oauth_token_url                   = var.grafana_oauth_token_url
    oauth_api_url                     = var.grafana_oauth_api_url
    oauth_role_attribute_path         = var.grafana_oauth_role_attribute_path

    # Grafana datasources (component enablement)
    enable_mimir     = var.enable_mimir
    enable_loki      = var.enable_loki
    enable_tempo     = var.enable_tempo
    enable_pyroscope = var.enable_pyroscope

    # Datasource URLs
    datasource_prometheus = local.datasource_urls.prometheus
    datasource_mimir      = local.datasource_urls.mimir
    datasource_loki       = local.datasource_urls.loki
    datasource_tempo      = local.datasource_urls.tempo
    datasource_pyroscope  = local.datasource_urls.pyroscope

    # Namespace references
    namespace_prometheus = local.namespaces.prometheus
    namespace_mimir      = local.namespaces.mimir
    namespace_loki       = local.namespaces.loki
    namespace_tempo      = local.namespaces.tempo
    namespace_pyroscope  = local.namespaces.pyroscope

    # Cloud-specific datasources
    enable_cloudwatch = var.enable_cloudwatch_datasource

    # Grafana alerting
    enable_alerting = var.grafana_enable_alerting

    # ============================================================
    # PROMETHEUS
    # ============================================================

    enable_prometheus         = var.enable_prometheus
    prometheus_retention      = var.prometheus_retention
    prometheus_retention_size = var.prometheus_retention_size
    prometheus_resources      = var.prometheus_resources
    prometheus_storage_size   = var.prometheus_storage_size

    # Prometheus remote write to Mimir
    mimir_remote_write_url = local.datasource_urls.mimir_push

    # Prometheus sub-components
    enable_alertmanager             = false
    enable_grafana                  = var.enable_grafana
    enable_node_exporter            = var.prometheus_enable_node_exporter
    enable_kube_state_metrics       = var.prometheus_enable_kube_state_metrics
    service_monitor_selector_labels = var.prometheus_service_monitor_selector

    # ============================================================
    # LOKI
    # ============================================================

    loki_retention_period = var.loki_retention_period
    loki_replicas         = var.loki_replicas
    loki_resources        = var.loki_resources
    loki_deployment_mode  = var.loki_deployment_mode

    # AWS IRSA
    loki_role_arn     = aws_iam_role.irsa["loki"].arn
    loki_bucket       = aws_s3_bucket.this["loki_chunks"].id
    loki_ruler_bucket = aws_s3_bucket.this["loki_ruler"].id


    # ============================================================
    # MIMIR
    # ============================================================

    mimir_retention_period   = var.mimir_retention_period
    mimir_replication_factor = var.mimir_replication_factor

    # AWS IRSA
    mimir_role_arn     = try(aws_iam_role.irsa["mimir"].arn, "")
    mimir_bucket       = try(aws_s3_bucket.this["mimir_blocks"].id, "")
    mimir_ruler_bucket = try(aws_s3_bucket.this["mimir_ruler"].id, "")


    # ============================================================
    # TEMPO
    # ============================================================

    tempo_retention_period = var.tempo_retention_period
    tempo_resources        = var.tempo_resources

    # AWS IRSA
    tempo_role_arn = try(aws_iam_role.irsa["tempo"].arn, "")
    tempo_bucket   = try(aws_s3_bucket.this["tempo"].id, "")


    # ============================================================
    # PYROSCOPE
    # ============================================================

    pyroscope_resources        = var.pyroscope_resources
    pyroscope_replicas         = var.pyroscope_replicas
    pyroscope_persistence_size = var.pyroscope_persistence_size

    # Alloy agent
    enable_alloy                  = var.pyroscope_enable_alloy
    excluded_profiling_namespaces = var.excluded_profiling_namespaces
  }
}
