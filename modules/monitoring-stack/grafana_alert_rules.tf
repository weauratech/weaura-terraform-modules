
resource "grafana_rule_group" "node_alerts" {
  count            = var.enable_grafana && var.enable_grafana_resources && var.enable_prometheus && var.enable_default_alert_rules ? 1 : 0
  name             = "Node Alerts"
  folder_uid       = grafana_folder.infrastructure[0].uid
  interval_seconds = 60
  depends_on       = [helm_release.monitoring]

  rule {
    name           = "HighNodeCPU"
    for            = "5m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "High Node CPU Usage"
      description = "Node {{ $labels.instance }} has High CPU Usage. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "infrastructure"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100) > 80"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "HighNodeMemory"
    for            = "5m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "High Node Memory Usage"
      description = "Node {{ $labels.instance }} has High Memory Usage. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "infrastructure"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100 > 85"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "NodeDiskSpaceLow"
    for            = "10m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "Node Disk Space Low"
      description = "Node {{ $labels.instance }} disk space is critically low. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "infrastructure"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "(1 - node_filesystem_avail_bytes{fstype!~\"tmpfs|overlay\"} / node_filesystem_size_bytes{fstype!~\"tmpfs|overlay\"}) * 100 > 85"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "NodeDiskSpaceCritical"
    for            = "5m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "Node Disk Space Critical"
      description = "Node {{ $labels.instance }} disk space is extremely critical. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "critical"
      category = "infrastructure"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "(1 - node_filesystem_avail_bytes{fstype!~\"tmpfs|overlay\"} / node_filesystem_size_bytes{fstype!~\"tmpfs|overlay\"}) * 100 > 95"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "HighNodeNetworkErrors"
    for            = "5m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "High Node Network Errors"
      description = "Node {{ $labels.instance }} has high network errors. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "infrastructure"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "rate(node_network_receive_errs_total[5m]) + rate(node_network_transmit_errs_total[5m]) > 10"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "NodeNotReady"
    for            = "5m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "Node Not Ready"
      description = "Node {{ $labels.node }} is not ready. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "critical"
      category = "infrastructure"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "kube_node_status_condition{condition=\"Ready\",status=\"true\"} == 0"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }
}

resource "grafana_rule_group" "pod_alerts" {
  count            = var.enable_grafana && var.enable_grafana_resources && var.enable_prometheus && var.enable_default_alert_rules ? 1 : 0
  name             = "Pod Alerts"
  folder_uid       = grafana_folder.kubernetes[0].uid
  interval_seconds = 60
  depends_on       = [helm_release.monitoring]

  rule {
    name           = "PodCrashLooping"
    for            = "5m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "Pod CrashLooping"
      description = "Pod {{ $labels.namespace }}/{{ $labels.pod }} is crash looping. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "critical"
      category = "kubernetes"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "rate(kube_pod_container_status_restarts_total[15m]) * 60 * 15 > 0"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "PodNotReady"
    for            = "15m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "Pod Not Ready"
      description = "Pod {{ $labels.namespace }}/{{ $labels.pod }} has been Pending or Unknown for 15m. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "kubernetes"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "kube_pod_status_phase{phase=~\"Pending|Unknown\"} > 0"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "ContainerOOMKilled"
    for            = "0s"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "Container OOMKilled"
      description = "Container {{ $labels.container }} in Pod {{ $labels.namespace }}/{{ $labels.pod }} was OOMKilled. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "critical"
      category = "kubernetes"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "kube_pod_container_status_last_terminated_reason{reason=\"OOMKilled\"} > 0"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "PodHighMemory"
    for            = "10m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "Pod High Memory"
      description = "Pod {{ $labels.namespace }}/{{ $labels.pod }} is using high memory. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "kubernetes"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "sum by (namespace, pod) (container_memory_working_set_bytes{container!=\"\"}) / sum by (namespace, pod) (kube_pod_container_resource_limits{resource=\"memory\"}) * 100 > 90"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "PodHighCPUThrottling"
    for            = "15m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "Pod High CPU Throttling"
      description = "Pod {{ $labels.namespace }}/{{ $labels.pod }} is being highly CPU throttled. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "kubernetes"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "sum by (namespace, pod) (rate(container_cpu_cfs_throttled_periods_total[5m])) / sum by (namespace, pod) (rate(container_cpu_cfs_periods_total[5m])) * 100 > 60"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }
}

resource "grafana_rule_group" "deployment_alerts" {
  count            = var.enable_grafana && var.enable_grafana_resources && var.enable_prometheus && var.enable_default_alert_rules ? 1 : 0
  name             = "Deployment Alerts"
  folder_uid       = grafana_folder.kubernetes[0].uid
  interval_seconds = 60
  depends_on       = [helm_release.monitoring]

  rule {
    name           = "DeploymentReplicasMismatch"
    for            = "15m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "Deployment Replicas Mismatch"
      description = "Deployment {{ $labels.namespace }}/{{ $labels.deployment }} replicas mismatch. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "kubernetes"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "kube_deployment_spec_replicas != kube_deployment_status_ready_replicas"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "StatefulSetReplicasMismatch"
    for            = "15m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "StatefulSet Replicas Mismatch"
      description = "StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} replicas mismatch. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "kubernetes"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "kube_statefulset_status_replicas_ready != kube_statefulset_status_replicas"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "DaemonSetNotScheduled"
    for            = "10m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "DaemonSet Not Scheduled"
      description = "DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} has unscheduled pods. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "kubernetes"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "kube_daemonset_status_desired_number_scheduled - kube_daemonset_status_current_number_scheduled > 0"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "HPA_MaxedOut"
    for            = "15m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "HPA Maxed Out"
      description = "HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler }} is maxed out. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "kubernetes"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "kube_horizontalpodautoscaler_status_current_replicas == kube_horizontalpodautoscaler_spec_max_replicas"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "JobFailed"
    for            = "0s"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "Job Failed"
      description = "Job {{ $labels.namespace }}/{{ $labels.job_name }} has failed. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "kubernetes"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "kube_job_status_failed > 0"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }
}

resource "grafana_rule_group" "persistent_volume_alerts" {
  count            = var.enable_grafana && var.enable_grafana_resources && var.enable_prometheus && var.enable_default_alert_rules ? 1 : 0
  name             = "Persistent Volume Alerts"
  folder_uid       = grafana_folder.infrastructure[0].uid
  interval_seconds = 60
  depends_on       = [helm_release.monitoring]

  rule {
    name           = "PVCAlmostFull"
    for            = "10m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "PVC Almost Full"
      description = "PVC {{ $labels.namespace }}/{{ $labels.persistentvolumeclaim }} is almost full. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "infrastructure"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "kubelet_volume_stats_used_bytes / kubelet_volume_stats_capacity_bytes * 100 > 85"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "PVCCriticallyFull"
    for            = "5m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "PVC Critically Full"
      description = "PVC {{ $labels.namespace }}/{{ $labels.persistentvolumeclaim }} is critically full. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "critical"
      category = "infrastructure"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "kubelet_volume_stats_used_bytes / kubelet_volume_stats_capacity_bytes * 100 > 95"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "PVCInodeExhaustion"
    for            = "10m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "PVC Inode Exhaustion"
      description = "PVC {{ $labels.namespace }}/{{ $labels.persistentvolumeclaim }} is running out of inodes. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "infrastructure"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "kubelet_volume_stats_inodes_used / kubelet_volume_stats_inodes * 100 > 90"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }
}

resource "grafana_rule_group" "cluster_alerts" {
  count            = var.enable_grafana && var.enable_grafana_resources && var.enable_prometheus && var.enable_default_alert_rules ? 1 : 0
  name             = "Cluster Alerts"
  folder_uid       = grafana_folder.sre[0].uid
  interval_seconds = 60
  depends_on       = [helm_release.monitoring]

  rule {
    name           = "HighAPIServerLatency"
    for            = "10m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "High API Server Latency"
      description = "Kubernetes API Server latency is high. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "sre"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "histogram_quantile(0.99, sum by (le, verb) (rate(apiserver_request_duration_seconds_bucket{verb!~\"WATCH|CONNECT\"}[5m]))) > 1"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "APIServerErrorRate"
    for            = "5m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "API Server Error Rate"
      description = "Kubernetes API Server error rate is high. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "critical"
      category = "sre"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "sum(rate(apiserver_request_total{code=~\"5..\"}[5m])) / sum(rate(apiserver_request_total[5m])) * 100 > 3"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "CorednsMisses"
    for            = "10m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "CoreDNS Cache Misses"
      description = "CoreDNS has a high rate of cache misses. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "sre"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "sum(rate(coredns_cache_misses_total[5m])) > 100"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "EtcdHighCommitDuration"
    for            = "10m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "Etcd High Commit Duration"
      description = "Etcd disk backend commit duration is high. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "sre"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "histogram_quantile(0.99, rate(etcd_disk_backend_commit_duration_seconds_bucket[5m])) > 0.25"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }

  rule {
    name           = "ClusterHighPodDensity"
    for            = "15m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "Error"
    annotations = {
      summary     = "Cluster High Pod Density"
      description = "Cluster has high pod density. Value: {{ $values.B.Value }}"
    }
    labels = {
      severity = "warning"
      category = "sre"
    }

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"
      model = jsonencode({
        expr  = "sum(kube_pod_status_phase{phase=\"Running\"}) / sum(kube_node_status_condition{condition=\"Ready\",status=\"true\"}) > 100"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      model = jsonencode({
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "A"
        reducer    = "last"
        refId      = "B"
        type       = "reduce"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        conditions = [{
          evaluator = {
            params = [-1]
            type   = "gt"
          }
          operator = {
            type = "and"
          }
          query = {
            params = ["B"]
          }
          reducer = {
            params = []
            type   = "last"
          }
          type = "query"
        }]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression = "B"
        refId      = "C"
        type       = "threshold"
      })
    }
  }
}
