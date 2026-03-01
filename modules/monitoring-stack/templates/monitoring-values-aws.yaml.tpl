# ============================================================
# WEAURA MONITORING STACK - AWS CONFIGURATION
# ============================================================
# Consolidated values template for umbrella chart deployment
# Uses 2-level nesting (e.g., loki.storage, not weaura-loki.loki.storage)
# Cloud-specific config via global.storage.provider = aws
# ============================================================

# ============================================================
# GLOBAL STORAGE CONFIGURATION
# ============================================================
global:
  storage:
    provider: aws
    aws:
      region: ${region}
      buckets:
        loki: ${loki_bucket}
        mimir: ${mimir_bucket}
        tempo: ${tempo_bucket}

# ============================================================
# GRAFANA - VISUALIZATION & DASHBOARDS
# ============================================================
grafana:
  enabled: ${enable_grafana}
  replicas: 1

  image:
    tag: "11.6.0"

  datasourceUrls:
    prometheus: "${datasource_prometheus}"
    loki: "${datasource_loki}"
    mimir: "${datasource_mimir}"
    tempo: "${datasource_tempo}"
    pyroscope: "${datasource_pyroscope}"

  # Deployment strategy - Recreate avoids PVC conflicts
  deploymentStrategy:
    type: Recreate

  # Persistence
  persistence:
    enabled: true
    size: ${grafana_storage_size}
    storageClassName: ${storage_class}

  # Environment variables
  # GF_INSTALL_PLUGINS is the standard env var for Grafana plugin installation
  env:
    GF_DATABASE_SQLITE_JOURNAL_MODE: wal
    GF_INSTALL_PLUGINS: "${join(",", grafana_plugins)}"
%{ if grafana_sso_enabled && grafana_sso_provider == "google" ~}
    # Google OAuth SSO - configured via environment variables
    GF_AUTH_GOOGLE_ENABLED: "true"
    GF_AUTH_GOOGLE_ALLOW_SIGN_UP: "true"
    GF_AUTH_GOOGLE_AUTO_LOGIN: "false"
    GF_AUTH_GOOGLE_SCOPES: "openid email profile"
    GF_AUTH_GOOGLE_AUTH_URL: "https://accounts.google.com/o/oauth2/auth"
    GF_AUTH_GOOGLE_TOKEN_URL: "https://oauth2.googleapis.com/token"
    GF_AUTH_GOOGLE_API_URL: "https://openidconnect.googleapis.com/v1/userinfo"
%{ if grafana_google_allowed_domains != "" ~}
    GF_AUTH_GOOGLE_ALLOWED_DOMAINS: "${grafana_google_allowed_domains}"
%{ endif ~}
    GF_AUTH_GOOGLE_USE_PKCE: "true"
%{ endif ~}
%{ if grafana_sso_enabled && grafana_sso_provider == "github" ~}
    # GitHub OAuth SSO via Generic OAuth (supports org/team checking with full control)
    # Secrets (client_id, client_secret) are injected via set_sensitive in Terraform
    GF_AUTH_GENERIC_OAUTH_ENABLED: "true"
    GF_AUTH_GENERIC_OAUTH_NAME: "GitHub"
    GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP: "true"
    GF_AUTH_GENERIC_OAUTH_AUTO_LOGIN: "false"
    GF_AUTH_GENERIC_OAUTH_SCOPES: "user:email read:org"
    GF_AUTH_GENERIC_OAUTH_AUTH_URL: "${oauth_auth_url != "" ? oauth_auth_url : "https://github.com/login/oauth/authorize"}"
    GF_AUTH_GENERIC_OAUTH_TOKEN_URL: "${oauth_token_url != "" ? oauth_token_url : "https://github.com/login/oauth/access_token"}"
    GF_AUTH_GENERIC_OAUTH_API_URL: "${oauth_api_url != "" ? oauth_api_url : "https://api.github.com/user"}"
    GF_AUTH_GENERIC_OAUTH_TEAMS_URL: "https://api.github.com/user/teams"
%{ if grafana_sso_allowed_organizations != "" ~}
    GF_AUTH_GENERIC_OAUTH_ALLOWED_ORGANIZATIONS: "${grafana_sso_allowed_organizations}"
%{ endif ~}
%{ if grafana_sso_team_ids != "" ~}
    GF_AUTH_GENERIC_OAUTH_TEAM_IDS: "${grafana_sso_team_ids}"
%{ endif ~}
    GF_AUTH_GENERIC_OAUTH_ROLE_ATTRIBUTE_PATH: "${oauth_role_attribute_path}"
%{ if grafana_sso_allow_assign_grafana_admin ~}
    GF_AUTH_GENERIC_OAUTH_ALLOW_ASSIGN_GRAFANA_ADMIN: "true"
%{ endif ~}
%{ endif ~}

  # Ingress - NGINX Ingress Controller
  # TLS Configuration:
  # - If tls_secret_name is provided: uses pre-existing secret (e.g., from External Secrets)
  # - If tls_secret_name is empty and cluster_issuer is set: uses cert-manager
  # - If both are empty: uses default secret name "grafana-tls"
  ingress:
    enabled: ${enable_ingress}
    ingressClassName: ${ingress_class}
    annotations:
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
      nginx.ingress.kubernetes.io/proxy-body-size: "50m"
      nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
      nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
%{ if tls_secret_name == "" && cluster_issuer != "" ~}
      cert-manager.io/cluster-issuer: "${cluster_issuer}"
%{ endif ~}
%{ for key, value in ingress_annotations ~}
      ${key}: "${value}"
%{ endfor ~}
    hosts:
      - ${grafana_domain}
%{ if enable_tls ~}
    tls:
      - secretName: ${tls_secret_name != "" ? tls_secret_name : (cluster_issuer != "" ? "grafana-tls" : "grafana-tls")}
        hosts:
          - ${grafana_domain}
%{ endif ~}

  # Sidecar - Dashboards only (datasources provisioned inline below)
  sidecar:
    dashboards:
      enabled: true
      label: grafana_dashboard
      labelValue: "1"
      searchNamespace: ALL
    datasources:
      enabled: false

  # Inline datasource provisioning (avoids sidecar PermissionError)
  # Datasources are conditionally created based on component toggles
  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
%{ if enable_prometheus ~}
        - name: Prometheus
          type: prometheus
          url: ${datasource_prometheus}
          access: proxy
          isDefault: true
          editable: true
          uid: prometheus
          jsonData:
            manageAlerts: false
%{ endif ~}
%{ if enable_loki ~}
        - name: Loki
          type: loki
          url: ${datasource_loki}
          access: proxy
          editable: true
          uid: loki
          jsonData:
            httpMethod: POST
            queryTimeout: 120s
            timeInterval: 30s
            maxLines: 5000
%{ endif ~}
%{ if enable_mimir ~}
        - name: Mimir
          type: prometheus
          url: ${datasource_mimir}
          access: proxy
          editable: true
          uid: mimir
          jsonData:
            timeInterval: 30s
            httpMethod: POST
%{ endif ~}
%{ if enable_tempo ~}
        - name: Tempo
          type: tempo
          url: ${datasource_tempo}
          access: proxy
          editable: true
          uid: tempo
          jsonData:
            httpMethod: GET
            nodeGraph:
              enabled: true
            traceQuery:
              timeShiftEnabled: true
              spanStartTimeShift: '-30m'
              spanEndTimeShift: '30m'
%{ if enable_loki ~}
            lokiSearch:
              datasourceUid: loki
            tracesToLogs:
              datasourceUid: loki
              filterByTraceID: true
%{ endif ~}
%{ endif ~}
%{ if enable_pyroscope ~}
        - name: Pyroscope
          type: grafana-pyroscope-datasource
          url: ${datasource_pyroscope}
          access: proxy
          editable: true
          uid: pyroscope
%{ endif ~}
  # Grafana.ini
  grafana.ini:
    server:
      root_url: https://${grafana_domain}
      domain: ${grafana_domain}

    # Authentication
    auth:
      disable_login_form: false
      oauth_auto_login: false

%{ if grafana_sso_enabled && grafana_sso_provider == "github" ~}
    # Generic OAuth configuration for GitHub (ini section required for teams_url)
    auth.generic_oauth:
      api_url: ${oauth_api_url != "" ? oauth_api_url : "https://api.github.com/user"}
      teams_url: https://api.github.com/user/teams
%{ endif ~}

    # Security
    security:
      admin_user: admin
      cookie_secure: true
      cookie_samesite: lax
      strict_transport_security: true

    # Analytics
    analytics:
      check_for_updates: false
      reporting_enabled: false

    # Unified Alerting - Enabled (Legacy Alerting was removed in Grafana 11+)
    # All alerting is now managed via Grafana's internal Alertmanager.
    # Contact points and notification policies are provisioned via Terraform.
    unified_alerting:
      enabled: true

    # Feature Toggles
    feature_toggles:
      enable: tempoSearch tempoBackendSearch tempoServiceGraph traceToMetrics lokiLogsDataplane lokiPredefinedOperations exploreLogs

  # Resources
  resources:
    requests:
      cpu: ${grafana_resources.requests.cpu}
      memory: ${grafana_resources.requests.memory}
    limits:
      cpu: ${grafana_resources.limits.cpu}
      memory: ${grafana_resources.limits.memory}

  # Node Selector
%{ if length(node_selector) > 0 ~}
  nodeSelector:
%{ for key, value in node_selector ~}
    ${key}: "${value}"
%{ endfor ~}
%{ endif ~}

  # Tolerations
%{ if length(tolerations) > 0 ~}
  tolerations:
%{ for toleration in tolerations ~}
    - key: "${toleration.key}"
      operator: "${toleration.operator}"
%{ if toleration.value != null ~}
      value: "${toleration.value}"
%{ endif ~}
      effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

# ============================================================
# LOKI - LOG AGGREGATION
# ============================================================
loki:
  enabled: ${enable_loki}

  # ServiceAccount - IRSA for S3 Access
  # IMPORTANT: ServiceAccount is created by Terraform (kubernetes.tf) with
  # Helm-compatible labels. This ensures the IRSA annotations are present
  # before the Helm chart is installed.
  serviceAccount:
    create: false
    name: loki
    annotations:
      eks.amazonaws.com/role-arn: ${loki_role_arn}

  global:
    clusterDomain: "cluster.local"
    dnsService: "kube-dns"
    dnsNamespace: "kube-system"

  deploymentMode: ${loki_deployment_mode}

  # Loki configuration
  loki:
    auth_enabled: false

    # Common config
    commonConfig:
      path_prefix: /var/loki
      replication_factor: 1

    # Storage configuration - S3 backend
    storage:
      type: s3
      bucketNames:
        chunks: ${loki_bucket}
        ruler: ${loki_ruler_bucket}
      s3:
        endpoint: s3.${region}.amazonaws.com
        region: ${region}
        s3ForcePathStyle: false
        insecure: false

    # Schema config
    schemaConfig:
      configs:
        - from: "2024-01-01"
          store: tsdb
          object_store: s3
          schema: v13
          index:
            prefix: loki_index_
            period: 24h

    # Limits config
    limits_config:
      reject_old_samples: true
      reject_old_samples_max_age: 168h
      max_cache_freshness_per_query: 10m
      split_queries_by_interval: 15m
      query_timeout: 180s
      volume_enabled: true
      retention_period: ${loki_retention_period}
      allow_structured_metadata: true
      max_query_parallelism: 32
      max_query_series: 500
      max_streams_per_user: 50000
      max_global_streams_per_user: 100000
      ingestion_rate_mb: 16
      ingestion_burst_size_mb: 32
      per_stream_rate_limit: 5MB
      per_stream_rate_limit_burst: 15MB
      max_line_size: 512KB
      max_label_names_per_series: 30
      max_label_name_length: 1024
      max_label_value_length: 2048
      max_concurrent_tail_requests: 10

    # Ingester config
    ingester:
      chunk_idle_period: 1m
      chunk_target_size: 1048576
      max_chunk_age: 5m
      wal:
        dir: /var/loki/wal
        flush_on_shutdown: true

    # Ruler config
    rulerConfig:
      wal:
        dir: /var/loki/ruler-wal
      enable_api: true
      storage:
        type: s3
        s3:
          region: ${region}
      rule_path: /var/loki/rules-temp
      ring:
        kvstore:
          store: inmemory

  # Compactor config
  compactor:
    working_directory: /var/loki/compactor
    compaction_interval: 5m
    retention_enabled: true
    retention_delete_delay: 2h
    retention_delete_worker_count: 50
    delete_request_store: s3

%{ if loki_deployment_mode == "SingleBinary" ~}
  # ============================================================
  # SingleBinary Mode - All components in a single pod
  # ============================================================
  singleBinary:
    replicas: 1
    persistence:
      enabled: true
      storageClass: ${storage_class}
      size: 10Gi
    resources:
      requests:
        cpu: ${loki_resources.requests.cpu}
        memory: ${loki_resources.requests.memory}
      limits:
        cpu: ${loki_resources.limits.cpu}
        memory: ${loki_resources.limits.memory}
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Disable microservices components
  write:
    replicas: 0
  read:
    replicas: 0
  backend:
    replicas: 0

  # Disable gateway and caches for SingleBinary
  gateway:
    enabled: false
  resultsCache:
    enabled: false
  chunksCache:
    enabled: false
%{ endif ~}

%{ if loki_deployment_mode == "SimpleScalable" ~}
  # ============================================================
  # SimpleScalable Mode - Loki deployed as write, read, backend
  # ============================================================
  singleBinary:
    replicas: 0

  # Write path (Ingester + Distributor)
  write:
    replicas: ${loki_replicas.write}
    persistence:
      volumeClaimsEnabled: false
    resources:
      requests:
        cpu: ${loki_resources.requests.cpu}
        memory: ${loki_resources.requests.memory}
      limits:
        cpu: ${loki_resources.limits.cpu}
        memory: ${loki_resources.limits.memory}
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}
    affinity:
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app.kubernetes.io/component: write
              topologyKey: kubernetes.io/hostname

  # Read path (Querier + Query Frontend)
  read:
    replicas: ${loki_replicas.read}
    resources:
      requests:
        cpu: ${loki_resources.requests.cpu}
        memory: ${loki_resources.requests.memory}
      limits:
        cpu: ${loki_resources.limits.cpu}
        memory: ${loki_resources.limits.memory}
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}
    affinity:
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app.kubernetes.io/component: read
              topologyKey: kubernetes.io/hostname

  # Backend (Compactor + Index Gateway + Ruler + Query Scheduler)
  backend:
    replicas: ${loki_replicas.backend}
    persistence:
      volumeClaimsEnabled: false
    resources:
      requests:
        cpu: ${loki_resources.requests.cpu}
        memory: ${loki_resources.requests.memory}
      limits:
        cpu: ${loki_resources.limits.cpu}
        memory: ${loki_resources.limits.memory}
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}
    affinity:
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app.kubernetes.io/component: backend
              topologyKey: kubernetes.io/hostname

  # Gateway
  gateway:
    enabled: true
    replicas: 1
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        memory: 256Mi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Caches - Memcached
  resultsCache:
    enabled: true
    replicas: 1
    allocatedMemory: 1024
    resources:
      requests:
        cpu: 100m
        memory: 1280Mi
      limits:
        memory: 1536Mi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  chunksCache:
    enabled: true
    replicas: 1
    allocatedMemory: 2048
    resources:
      requests:
        cpu: 100m
        memory: 2560Mi
      limits:
        memory: 3072Mi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}
%{ endif ~}

  # Disabled components
  minio:
    enabled: false

  lokiCanary:
    enabled: false

  test:
    enabled: false

  # Monitoring
  monitoring:
    dashboards:
      enabled: true
      labels:
        grafana_dashboard: "1"
    rules:
      enabled: true
      alerting: false  # Alerts managed by Grafana Unified Alerting
    serviceMonitor:
      enabled: true
      labels:
        release: prometheus

# ============================================================
# MIMIR - LONG-TERM METRICS STORAGE
# ============================================================
mimir:
  enabled: ${enable_mimir}

  # ServiceAccount - IRSA for S3 Access
  # IMPORTANT: ServiceAccount is created by Terraform (kubernetes.tf) with
  # Helm-compatible labels. This ensures the IRSA annotations are present
  # before the Helm chart is installed.
  serviceAccount:
    create: false
    name: mimir
    annotations:
      eks.amazonaws.com/role-arn: ${mimir_role_arn}

  # Global configuration
  global:
    clusterDomain: cluster.local

  # Disable multi-tenancy (single tenant)
  multitenancyEnabled: false

  # Mimir configuration
  mimir:
    structuredConfig:
      # Storage backend - handled by chart via global.storage
      # Chart translates global.storage.aws.* to Mimir-specific S3 config

      # Blocks storage (TSDB) - S3
      blocks_storage:
        tsdb:
          dir: /data/tsdb
          ship_interval: 15m
          head_compaction_interval: 5m
          head_compaction_concurrency: 1
          head_compaction_idle_timeout: 1h
          block_ranges_period: ["2h", "12h", "24h"]
          retention_period: ${mimir_retention_period}
          flush_blocks_on_shutdown: true

      # Compactor
      compactor:
        data_dir: /data/compactor
        sharding_ring:
          kvstore:
            store: memberlist
        compaction_interval: 15m
        compaction_concurrency: 1

      # Distributor
      distributor:
        ring:
          kvstore:
            store: memberlist
        pool:
          health_check_ingesters: true

      # Ingester
      ingester:
        ring:
          kvstore:
            store: memberlist
          replication_factor: ${mimir_replication_factor}
          heartbeat_period: 5s
          heartbeat_timeout: 1m

      # Store Gateway
      store_gateway:
        sharding_ring:
          kvstore:
            store: memberlist

      # Querier
      querier:
        timeout: 2m
        max_concurrent: 20

      # Limits - adjusted for production environment
      limits:
        max_global_series_per_user: 3000000
        max_global_series_per_metric: 100000
        ingestion_rate: 200000
        ingestion_burst_size: 400000
        max_label_names_per_series: 50
        max_label_value_length: 2048
        max_query_length: 721h
        max_query_parallelism: 32
        out_of_order_time_window: 1h

  # Gateway (nginx)
  gateway:
    replicas: 1
    resources:
      requests:
        cpu: 500m
        memory: 512Mi
      limits:
        cpu: 1
        memory: 731Mi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Distributor - receives metrics from Prometheus
  distributor:
    replicas: 2
    resources:
      requests:
        cpu: 1
        memory: 2Gi
      limits:
        cpu: 2
        memory: 4Gi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Ingester - stores metrics in memory
  ingester:
    replicas: 3
    persistentVolume:
      enabled: true
      size: 50Gi
      storageClass: ${storage_class}
    resources:
      requests:
        cpu: 1
        memory: 4Gi
      limits:
        cpu: 2
        memory: 8Gi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}
    topologySpreadConstraints: {}
    affinity:
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                  - key: app.kubernetes.io/component
                    operator: In
                    values:
                      - ingester
              topologyKey: "kubernetes.io/hostname"

  # Querier - executes queries
  querier:
    replicas: 1
    resources:
      requests:
        cpu: 500m
        memory: 2Gi
      limits:
        cpu: 2
        memory: 4Gi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Query Frontend
  query_frontend:
    replicas: 1
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 2
        memory: 2Gi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Store Gateway - serves blocks from S3
  store_gateway:
    replicas: 3
    persistentVolume:
      enabled: true
      size: 10Gi
      storageClass: ${storage_class}
    resources:
      requests:
        cpu: 250m
        memory: 1Gi
      limits:
        cpu: 1
        memory: 2Gi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}
    topologySpreadConstraints: {}
    affinity:
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                  - key: app.kubernetes.io/component
                    operator: In
                    values:
                      - store-gateway
              topologyKey: "kubernetes.io/hostname"

  # Compactor - compacts blocks
  compactor:
    replicas: 1
    persistentVolume:
      enabled: true
      size: 20Gi
      storageClass: ${storage_class}
    resources:
      requests:
        cpu: 250m
        memory: 1Gi
      limits:
        cpu: 1
        memory: 2Gi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Ruler
  ruler:
    replicas: 1
    resources:
      requests:
        cpu: 250m
        memory: 1Gi
      limits:
        cpu: 1
        memory: 2Gi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Overrides Exporter
  overrides_exporter:
    replicas: 1
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Caches - Memcached (recommended for performance)
  # Chunks Cache
  chunks-cache:
    enabled: true
    replicas: 2
    resources:
      requests:
        cpu: 100m
        memory: 512Mi
      limits:
        cpu: 500m
        memory: 1Gi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Index Cache
  index-cache:
    enabled: true
    replicas: 2
    resources:
      requests:
        cpu: 100m
        memory: 512Mi
      limits:
        cpu: 500m
        memory: 1Gi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Metadata Cache
  metadata-cache:
    enabled: true
    replicas: 2
    resources:
      requests:
        cpu: 100m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 512Mi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Results Cache
  results-cache:
    enabled: true
    replicas: 2
    resources:
      requests:
        cpu: 100m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 512Mi
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Disabled components
  # Alertmanager (using Grafana Unified Alerting)
  alertmanager:
    enabled: false

  # MinIO (using S3 directly)
  minio:
    enabled: false

  # Rollout Operator - disabled to avoid architecture errors
  rollout_operator:
    enabled: false

  # Monitoring
  monitoring:
    dashboards:
      enabled: true
      labels:
        grafana_dashboard: "1"
    rules:
      enabled: true
      alerting: true
    serviceMonitor:
      enabled: true
      labels:
        release: prometheus

# ============================================================
# TEMPO - DISTRIBUTED TRACING
# ============================================================
tempo:
  enabled: ${enable_tempo}

  # Multi-tenancy enabled for isolation
  multitenancyEnabled: true

  # ServiceAccount - IRSA for S3 Access
  # IMPORTANT: ServiceAccount is created by Terraform (kubernetes.tf) with
  # Helm-compatible labels. This ensures the IRSA annotations are present
  # before the Helm chart is installed.
  serviceAccount:
    create: false
    name: tempo
    annotations:
      eks.amazonaws.com/role-arn: ${tempo_role_arn}

  # Storage - handled by chart via global.storage
  # Chart translates global.storage.aws.* to Tempo-specific S3 config

  # Traces receivers
  traces:
    otlp:
      grpc:
        enabled: true
        receiverConfig:
          endpoint: 0.0.0.0:4317
      http:
        enabled: true
    jaeger:
      grpc:
        enabled: false
      thriftHttp:
        enabled: false
    zipkin:
      enabled: false

  # Distributor - receives traces
  distributor:
    replicas: 2
    resources:
      requests:
        cpu: ${tempo_resources.requests.cpu}
        memory: ${tempo_resources.requests.memory}
      limits:
        cpu: ${tempo_resources.limits.cpu}
        memory: ${tempo_resources.limits.memory}
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Ingester - processes and stores traces
  ingester:
    replicas: 2
    config:
      max_block_duration: 30m
      trace_idle_period: 30s
      flush_check_period: 5s
      complete_block_timeout: 6m
    resources:
      requests:
        cpu: ${tempo_resources.requests.cpu}
        memory: ${tempo_resources.requests.memory}
      limits:
        cpu: ${tempo_resources.limits.cpu}
        memory: ${tempo_resources.limits.memory}
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Compactor - compacts blocks
  compactor:
    replicas: 1
    config:
      compaction:
        block_retention: ${tempo_retention_period}
    resources:
      requests:
        cpu: ${tempo_resources.requests.cpu}
        memory: ${tempo_resources.requests.memory}
      limits:
        cpu: ${tempo_resources.limits.cpu}
        memory: ${tempo_resources.limits.memory}
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Querier - executes queries
  querier:
    replicas: 2
    resources:
      requests:
        cpu: ${tempo_resources.requests.cpu}
        memory: ${tempo_resources.requests.memory}
      limits:
        cpu: ${tempo_resources.limits.cpu}
        memory: ${tempo_resources.limits.memory}
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Query Frontend
  queryFrontend:
    replicas: 2
    config:
      metrics:
        max_duration: 168h         # 7 days of history allowed
        query_backend_after: 30m   # use local/ingesters metrics for recent window
    resources:
      requests:
        cpu: ${tempo_resources.requests.cpu}
        memory: ${tempo_resources.requests.memory}
      limits:
        cpu: ${tempo_resources.limits.cpu}
        memory: ${tempo_resources.limits.memory}
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Metrics Generator - generates metrics from traces
  # Chart handles remoteWriteUrl conditionally based on mimir.enabled
  metricsGenerator:
    enabled: true
    replicas: 1
    walEmptyDir:
      sizeLimit: 5Gi
    config:
      processor:
        local_blocks:
          max_block_duration: 30m
          trace_idle_period: 1m
          flush_check_period: 30s
      storage:
        path: /var/tempo/wal
        # remote_write removed - chart handles conditionally
      traces_storage:
        path: /var/tempo/traces
    resources:
      requests:
        cpu: ${tempo_resources.requests.cpu}
        memory: ${tempo_resources.requests.memory}
      limits:
        cpu: ${tempo_resources.limits.cpu}
        memory: ${tempo_resources.limits.memory}
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Overrides
  overrides:
    defaults:
      metrics_generator:
        processors:
          - service-graphs
          - span-metrics
          - local-blocks

  # Monitoring
  monitoring:
    dashboards:
      enabled: true
      labels:
        grafana_dashboard: "1"
    rules:
      enabled: true
      alerting: true
    serviceMonitor:
      enabled: true
      labels:
        release: prometheus

# ============================================================
# PYROSCOPE - CONTINUOUS PROFILING
# ============================================================
pyroscope:
  enabled: ${enable_pyroscope}

  # Pyroscope configuration
  pyroscope:
    replicaCount: 1

    # Resources
    resources:
      requests:
        cpu: ${pyroscope_resources.requests.cpu}
        memory: ${pyroscope_resources.requests.memory}
      limits:
        cpu: ${pyroscope_resources.limits.cpu}
        memory: ${pyroscope_resources.limits.memory}

    # Environment variables for memberlist configuration
    # Fixes "no private IP address found" error by explicitly setting POD_IP
    extraEnv:
      - name: POD_IP
        valueFrom:
          fieldRef:
            fieldPath: status.podIP

    # Extra args to configure memberlist advertise address
    # NOTE: Format must be a map (key: value), not a list of strings
    extraArgs:
      "memberlist.advertise-addr": "$(POD_IP)"
      "memberlist.advertise-port": "7946"

    # Node Selector - run on observability nodes
%{ if length(node_selector) > 0 ~}
    nodeSelector:
%{ for key, value in node_selector ~}
      ${key}: "${value}"
%{ endfor ~}
%{ endif ~}

    # Tolerations - tolerate observability taint
%{ if length(tolerations) > 0 ~}
    tolerations:
%{ for toleration in tolerations ~}
      - key: "${toleration.key}"
        operator: "${toleration.operator}"
%{ if toleration.value != null ~}
        value: "${toleration.value}"
%{ endif ~}
        effect: "${toleration.effect}"
%{ endfor ~}
%{ endif ~}

  # Alloy Agent - collects profiling automatically via eBPF/perf
  # No need to modify applications
  # IMPORTANT: DaemonSet runs on ALL nodes (no nodeSelector)
  alloy:
    enabled: true

    # DaemonSet to collect profiling from all pods on each node
    mode: daemonset

    # Tolerations - tolerate ALL taints to run on every node
    tolerations:
      - operator: "Exists"

    # Configuration for automatic profiling collection
    configMap:
      create: true
      content: |
        # Discover all pods in the cluster
        discovery.kubernetes "pods" {
          role = "pod"
        }

        # Collect profiling from discovered pods
        pyroscope.scrape "profiles" {
          targets = discovery.kubernetes.pods.targets
          forward_to = [pyroscope.write.profiles.receiver]

          # Filter system/infrastructure namespaces
          relabel_configs {
            source_labels = ["__meta_kubernetes_namespace"]
            regex = "^(${join("|", excluded_profiling_namespaces)})$"
            action = "drop"
          }
        }

        pyroscope.write "profiles" {
          endpoint {
            url = "http://pyroscope.${namespace_pyroscope}.svc.cluster.local:4040"
          }
        }

    # Alloy resources
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 512Mi

    # RBAC required to discover pods
    rbac:
      create: true

    # ServiceAccount
    serviceAccount:
      create: true

    # Security context for eBPF/perf (requires capabilities)
    securityContext:
      capabilities:
        add:
          - SYS_ADMIN
          - SYS_RESOURCE
          - DAC_OVERRIDE
          - PERFMON
          - BPF
      privileged: true  # Required for eBPF profiling
      runAsUser: 0      # Needs to run as root for eBPF

  # Monitoring
  monitoring:
    dashboards:
      enabled: true
      labels:
        grafana_dashboard: "1"
    rules:
      enabled: true
      alerting: false
    serviceMonitor:
      enabled: true
      labels:
        release: prometheus
