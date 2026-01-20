# ============================================================
# Harbor Helm Values Template
# ============================================================
# Template for Harbor Helm chart values.
# Configured for AWS EKS with ALB ingress, S3 storage,
# internal PostgreSQL and Redis.
# ============================================================

# --------------------------------
# External URL Configuration
# --------------------------------
externalURL: "${external_url}"

# --------------------------------
# Ingress Configuration (ALB)
# --------------------------------
expose:
  type: ingress
  tls:
    enabled: false  # TLS is terminated at ALB
  ingress:
    hosts:
      core: "${hostname}"
    controller: default
    className: "${ingress_class}"
    annotations:
%{ for key, value in ingress_annotations ~}
      ${key}: '${replace(value, "'", "''")}'
%{ endfor ~}

# --------------------------------
# Internal TLS (disabled - using ALB termination)
# --------------------------------
internalTLS:
  enabled: false

# --------------------------------
# Persistence Configuration (S3)
# --------------------------------
persistence:
  enabled: true
  resourcePolicy: "keep"
  persistentVolumeClaim:
    registry:
      existingClaim: ""
      storageClass: ""
      subPath: ""
      accessMode: ReadWriteOnce
      size: 5Gi
    jobservice:
      jobLog:
        existingClaim: ""
        storageClass: "${storage_class}"
        subPath: ""
        accessMode: ReadWriteOnce
        size: 1Gi
  imageChartStorage:
    disableredirect: false
    type: s3
    s3:
      region: "${aws_region}"
      bucket: "${s3_bucket_name}"
      # Use IRSA - no access keys needed
      # accesskey and secretkey are intentionally empty
      # Harbor will use IAM role attached to the service account
      regionendpoint: "https://s3.${aws_region}.amazonaws.com"
      encrypt: ${s3_encrypted}
%{ if s3_kms_key_id != "" ~}
      keyid: "${s3_kms_key_id}"
%{ endif ~}
      secure: true
      v4auth: true
      chunksize: 5242880
      multipartcopychunksize: 33554432
      multipartcopymaxconcurrency: 100
      multipartcopythresholdsize: 33554432
      rootdirectory: "/"

# --------------------------------
# Database Configuration (Internal PostgreSQL)
# --------------------------------
database:
  type: internal
  internal:
    image:
      repository: goharbor/harbor-db
      tag: "${harbor_version}"
    password: "${database_password}"
    shmSizeLimit: 512Mi
    livenessProbe:
      timeoutSeconds: 1
    readinessProbe:
      timeoutSeconds: 1
    nodeSelector: ${jsonencode(node_selector)}
    tolerations: ${jsonencode(tolerations)}
    resources:
      requests:
        memory: 256Mi
        cpu: 100m
      limits:
        memory: 1Gi
        cpu: 500m
  podAnnotations: {}
  maxIdleConns: 100
  maxOpenConns: 900
  
# PostgreSQL persistence
postgresql:
  persistence:
    enabled: true
    size: "${database_storage_size}"
    storageClass: "${database_storage_class}"

# --------------------------------
# Redis Configuration (Internal)
# --------------------------------
redis:
  type: internal
  internal:
    image:
      repository: goharbor/redis-photon
      tag: "${harbor_version}"
    nodeSelector: ${jsonencode(node_selector)}
    tolerations: ${jsonencode(tolerations)}
    resources:
      requests:
        memory: 64Mi
        cpu: 50m
      limits:
        memory: 256Mi
        cpu: 200m
  podAnnotations: {}

# Redis persistence
redis-persistence:
  enabled: true
  size: "${redis_storage_size}"
  storageClass: "${redis_storage_class}"

# --------------------------------
# Harbor Core
# --------------------------------
core:
  replicas: ${core_replicas}
  revisionHistoryLimit: 3
  startupProbe:
    enabled: true
    initialDelaySeconds: 10
  serviceAccountName: "${registry_service_account}"
  automountServiceAccountToken: true
  image:
    repository: goharbor/harbor-core
    tag: "${harbor_version}"
  resources:
    requests:
      memory: "${core_resources_requests_memory}"
      cpu: "${core_resources_requests_cpu}"
    limits:
      memory: "${core_resources_limits_memory}"
      cpu: "${core_resources_limits_cpu}"
  nodeSelector: ${jsonencode(node_selector)}
  tolerations: ${jsonencode(tolerations)}
  podAnnotations: {}
  serviceAnnotations: {}
  configureUserSettings: ""
  quotaUpdateProvider: db
  secret: "${harbor_secret_key}"
  secretName: ""
  xsrfKey: ""
  # Metrics
  metrics:
    enabled: true
    port: 8001
    path: /metrics

# --------------------------------
# JobService
# --------------------------------
jobservice:
  replicas: ${jobservice_replicas}
  revisionHistoryLimit: 3
  maxJobWorkers: 10
  jobLoggers:
    - file
  loggerSweeperDuration: 14
  notification:
    webhook_job_max_retry: 10
  reaper:
    max_update_hours: 24
    max_dangling_hours: 168
  image:
    repository: goharbor/harbor-jobservice
    tag: "${harbor_version}"
  resources:
    requests:
      memory: "${jobservice_resources_requests_memory}"
      cpu: "${jobservice_resources_requests_cpu}"
    limits:
      memory: "${jobservice_resources_limits_memory}"
      cpu: "${jobservice_resources_limits_cpu}"
  nodeSelector: ${jsonencode(node_selector)}
  tolerations: ${jsonencode(tolerations)}
  podAnnotations: {}

# --------------------------------
# Registry
# --------------------------------
registry:
  replicas: ${registry_replicas}
  revisionHistoryLimit: 3
  serviceAccountName: "${registry_service_account}"
  automountServiceAccountToken: true
  registry:
    image:
      repository: goharbor/registry-photon
      tag: "${harbor_version}"
    resources:
      requests:
        memory: "${registry_resources_requests_memory}"
        cpu: "${registry_resources_requests_cpu}"
      limits:
        memory: "${registry_resources_limits_memory}"
        cpu: "${registry_resources_limits_cpu}"
  controller:
    image:
      repository: goharbor/harbor-registryctl
      tag: "${harbor_version}"
    resources:
      requests:
        memory: 64Mi
        cpu: 50m
      limits:
        memory: 256Mi
        cpu: 200m
  nodeSelector: ${jsonencode(node_selector)}
  tolerations: ${jsonencode(tolerations)}
  podAnnotations: {}
  upload_purging:
    enabled: true
    age: 168h
    interval: 24h
    dryrun: false
  # Metrics
  metrics:
    enabled: true
    port: 8001
    path: /metrics

# --------------------------------
# Portal
# --------------------------------
portal:
  replicas: ${portal_replicas}
  revisionHistoryLimit: 3
  image:
    repository: goharbor/harbor-portal
    tag: "${harbor_version}"
  resources:
    requests:
      memory: "${portal_resources_requests_memory}"
      cpu: "${portal_resources_requests_cpu}"
    limits:
      memory: "${portal_resources_limits_memory}"
      cpu: "${portal_resources_limits_cpu}"
  nodeSelector: ${jsonencode(node_selector)}
  tolerations: ${jsonencode(tolerations)}
  podAnnotations: {}

# --------------------------------
# Trivy (Vulnerability Scanner)
# --------------------------------
trivy:
  enabled: ${enable_trivy}
  replicas: ${trivy_replicas}
  image:
    repository: goharbor/trivy-adapter-photon
    tag: "${harbor_version}"
  resources:
    requests:
      memory: "${trivy_resources_requests_memory}"
      cpu: "${trivy_resources_requests_cpu}"
    limits:
      memory: "${trivy_resources_limits_memory}"
      cpu: "${trivy_resources_limits_cpu}"
  nodeSelector: ${jsonencode(node_selector)}
  tolerations: ${jsonencode(tolerations)}
  podAnnotations: {}
  debugMode: false
  vulnType: "os,library"
  severity: "UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL"
  ignoreUnfixed: false
  insecure: false
  skipUpdate: false
  skipJavaDBUpdate: false
  offlineScan: false
  timeout: 5m0s
  gitHubToken: ""

# --------------------------------
# Notary (disabled)
# --------------------------------
notary:
  enabled: false

# --------------------------------
# Exporter (Metrics)
# --------------------------------
exporter:
  replicas: 1
  revisionHistoryLimit: 3
  image:
    repository: goharbor/harbor-exporter
    tag: "${harbor_version}"
  resources:
    requests:
      memory: 64Mi
      cpu: 50m
    limits:
      memory: 128Mi
      cpu: 100m
  nodeSelector: ${jsonencode(node_selector)}
  tolerations: ${jsonencode(tolerations)}
  podAnnotations: {}
  cacheDuration: 23
  cacheCleanInterval: 14400

# --------------------------------
# Metrics Configuration
# --------------------------------
metrics:
  enabled: true
  core:
    path: /metrics
    port: 8001
  registry:
    path: /metrics
    port: 8001
  jobservice:
    path: /metrics
    port: 8001
  exporter:
    path: /metrics
    port: 8001
  serviceMonitor:
    enabled: false

# --------------------------------
# Caching
# --------------------------------
cache:
  enabled: true
  expireHours: 24

# --------------------------------
# Harbor Admin Password
# --------------------------------
harborAdminPassword: "${admin_password}"

# --------------------------------
# Update Strategy
# --------------------------------
updateStrategy:
  type: RollingUpdate

# --------------------------------
# Log Level
# --------------------------------
logLevel: info

# --------------------------------
# Secret Key (for encryption)
# --------------------------------
secretKey: "${harbor_secret_key}"

# --------------------------------
# Proxy Configuration (if needed)
# --------------------------------
proxy:
  httpProxy: ""
  httpsProxy: ""
  noProxy: "127.0.0.1,localhost,.local,.internal"
  components:
    - core
    - jobservice
    - trivy

# --------------------------------
# Enable IPV6
# --------------------------------
ipFamily:
  ipv6:
    enabled: false
