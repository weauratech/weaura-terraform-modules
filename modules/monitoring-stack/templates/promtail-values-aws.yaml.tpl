config:
  clients:
    - url: "${loki_push_url}"
      tenant_id: ""

  snippets:
    pipelineStages:
      - cri: {}
      - docker: {}
%{ if length(target_namespaces) > 0 ~}
    extraRelabelConfigs:
      - action: keep
        source_labels:
          - __meta_kubernetes_namespace
        regex: "${join("|", target_namespaces)}"
%{ endif ~}

resources:
  limits:
    cpu: 200m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 64Mi

tolerations:
  - effect: NoSchedule
    operator: Exists

serviceMonitor:
  enabled: false
