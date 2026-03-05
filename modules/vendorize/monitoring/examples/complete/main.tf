# ============================================================
# Complete Example - WeAura Monitoring Stack
# ============================================================
# This example demonstrates a complete production deployment
# of the WeAura monitoring stack with all components enabled,
# enterprise features, Harbor-based chart distribution, and
# additional AWS resources (CloudWatch alarms, SNS).
# ============================================================

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.79.0"
    }
  }
}

# --------------------------------
# Provider Configuration
# --------------------------------

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "WeAura Monitoring"
      ManagedBy   = "Terraform"
      Environment = var.environment
      Owner       = var.owner
    }
  }
}

# Configure Kubernetes provider (auto-configured from EKS)
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# --------------------------------
# Monitoring Stack Module
# --------------------------------

module "monitoring_stack" {
  source = "../../"

  cluster_name     = var.cluster_name
  region           = var.region
  namespace        = var.namespace
  create_namespace = true
  chart_version    = "0.15.0"

  # Harbor registry (replaces ECR)
  harbor_url      = var.harbor_url
  harbor_username = var.harbor_username
  harbor_password = var.harbor_password

  # Cloud & IAM
  cloud_provider = "aws"
  iam_mode       = "irsa"
  sizing_preset  = var.sizing_preset

  # Enterprise features demo
  pdb_enabled                 = true
  alert_rules_enabled         = true
  service_monitor_auto_enable = true

  # AWS config
  aws_config = {
    s3_bucket_prefix = var.s3_bucket_prefix != "" ? var.s3_bucket_prefix : "${var.cluster_name}-monitoring"
  }

  # Grafana Configuration
  grafana = {
    enabled             = true
    admin_password      = var.grafana_admin_password
    ingress_enabled     = var.enable_ingress
    ingress_host        = var.grafana_ingress_host
    storage_size        = "20Gi"
    persistence_enabled = true
  }

  # Loki Configuration (Logs)
  loki = {
    enabled      = true
    storage_size = var.loki_storage_size
    retention    = var.loki_retention
  }

  # Mimir Configuration (Metrics - Long-term)
  mimir = {
    enabled      = true
    storage_size = var.mimir_storage_size
    retention    = var.mimir_retention
  }

  # Tempo Configuration (Traces)
  tempo = {
    enabled      = true
    storage_size = var.tempo_storage_size
    retention    = var.tempo_retention
  }

  # Prometheus Configuration (Metrics - Short-term)
  prometheus = {
    enabled      = true
    storage_size = var.prometheus_storage_size
    retention    = var.prometheus_retention
  }

  # Pyroscope Configuration (Profiling)
  pyroscope = {
    enabled      = true
    storage_size = var.pyroscope_storage_size
  }

  # Additional Helm values for customization
  helm_values = var.additional_helm_values

  tags = {
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    Backup      = "daily"
  }
}

# --------------------------------
# Optional: CloudWatch Alarms for S3 Buckets
# --------------------------------

resource "aws_cloudwatch_metric_alarm" "s3_bucket_size" {
  for_each = toset(["loki", "mimir", "tempo", "pyroscope"])

  alarm_name          = "${var.cluster_name}-monitoring-${each.key}-bucket-size"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = "86400" # 1 day
  statistic           = "Average"
  threshold           = var.s3_size_alarm_threshold_gb * 1073741824 # Convert GB to bytes
  alarm_description   = "Alert when ${each.key} S3 bucket exceeds ${var.s3_size_alarm_threshold_gb}GB"
  treat_missing_data  = "notBreaching"

  dimensions = {
    BucketName  = module.monitoring_stack.s3_buckets[each.key]
    StorageType = "StandardStorage"
  }

  tags = {
    Component = each.key
  }
}

# --------------------------------
# Optional: SNS Topic for Alarms
# --------------------------------

resource "aws_sns_topic" "monitoring_alerts" {
  count = var.enable_sns_alerts ? 1 : 0

  name = "${var.cluster_name}-monitoring-alerts"

  tags = {
    Purpose = "monitoring-alerts"
  }
}

resource "aws_sns_topic_subscription" "monitoring_alerts_email" {
  count = var.enable_sns_alerts && var.alert_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.monitoring_alerts[0].arn
  protocol  = "email"
  endpoint  = var.alert_email
}
