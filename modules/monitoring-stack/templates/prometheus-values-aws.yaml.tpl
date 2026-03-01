# ============================================================
# PROMETHEUS VALUES (kube-prometheus-stack - standalone)
# ============================================================
# Extracted from the umbrella chart to avoid Helm release size
# limits. These values are for the standalone kube-prometheus-stack
# Helm release.
# ============================================================

# Override the release name for predictable service naming
# Prometheus server service: weaura-prometheus-prometheus
fullnameOverride: "weaura-prometheus"

# Skip CRD installation (CRDs pre-applied to cluster)
crds:
  enabled: false

# Disable Grafana (we have a separate one)
grafana:
  enabled: false
  defaultDashboardsEnabled: true
  forceDeployDashboards: true

# Disable default kube-prometheus-stack alerts
# Only custom alerts are used
defaultRules:
  create: false

# Prometheus Operator
prometheusOperator:
  enabled: true

  # Disable admission webhooks and TLS on operator web server.
  # The admission webhook patch job creates secrets with standard TLS keys
  # (tls.crt/tls.key), but without cert-manager the operator expects non-standard
  # keys (cert/key). Additionally, Kubernetes API server requires HTTPS for
  # webhooks, so webhooks cannot work without TLS. Since we manage Prometheus
  # rules via Terraform (not kubectl), CRD validation webhooks are not needed.
  # Re-enable with cert-manager if webhook validation is desired.
  tls:
    enabled: false
  admissionWebhooks:
    enabled: false

  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 256Mi
  # Node scheduling for operator
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

# Prometheus
prometheus:
  enabled: true
  prometheusSpec:
    # Persistence
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: ${storage_class}
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: ${prometheus_storage_size}

    # Resources
    resources:
      requests:
        cpu: ${prometheus_resources.requests.cpu}
        memory: ${prometheus_resources.requests.memory}
      limits:
        cpu: ${prometheus_resources.limits.cpu}
        memory: ${prometheus_resources.limits.memory}

    # Node scheduling for Prometheus server
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

    # Local retention (short-term)
    # Long-term metrics are sent to Mimir via remote write
    retention: ${prometheus_retention}

    # Remote write to Mimir - REMOVED (chart handles conditionally)
    # Chart auto-configures remoteWrite based on mimir.enabled

    # PrometheusRule discovery
    ruleSelector: {}
    ruleNamespaceSelector: {}
    # ServiceMonitor discovery
    serviceMonitorSelector:
      matchLabels: {}
    serviceMonitorNamespaceSelector: {}

    # PodMonitor discovery
    podMonitorSelector:
      matchLabels: {}
    podMonitorNamespaceSelector: {}

    # Additional scrape configurations
    additionalScrapeConfigs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__
          - action: labelmap
            regex: __meta_kubernetes_pod_label_(.+)
          - source_labels: [__meta_kubernetes_namespace]
            action: replace
            target_label: namespace
          - source_labels: [__meta_kubernetes_pod_name]
            action: replace
            target_label: pod

      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
          - role: node
        relabel_configs:
          - action: labelmap
            regex: __meta_kubernetes_node_label_(.+)

# Alertmanager - DISABLED
# Alerting is now handled by Grafana Unified Alerting.
# Contact points and notification policies are managed via Terraform Grafana Provider.
alertmanager:
  enabled: false

# Node Exporter (DaemonSet - runs on ALL nodes)
nodeExporter:
  enabled: true

prometheus-node-exporter:
  enabled: true
  affinity: {}
  # DaemonSet tolerates ANY taint to run on all nodes
  tolerations:
    - operator: "Exists"
  resources:
    requests:
      cpu: 25m
      memory: 64Mi
    limits:
      cpu: 200m
      memory: 256Mi

# Kube State Metrics
kubeStateMetrics:
  enabled: true

kube-state-metrics:
  # Node scheduling for kube-state-metrics
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
