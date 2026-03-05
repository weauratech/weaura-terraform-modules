# ============================================================
# S3 Buckets for Monitoring Stack Storage
# ============================================================
# Creates S3 buckets for Loki, Mimir, Tempo, and Pyroscope
# when deploying on AWS.
# ============================================================

# --------------------------------
# Loki S3 Bucket
# --------------------------------

resource "aws_s3_bucket" "loki" {
  count = var.cloud_provider == "aws" && var.loki.enabled ? 1 : 0

  bucket = local.loki_s3_bucket

  tags = merge(
    local.common_tags,
    {
      Component = "loki"
      Purpose   = "log-storage"
    }
  )
}

resource "aws_s3_bucket_versioning" "loki" {
  count = var.cloud_provider == "aws" && var.loki.enabled ? 1 : 0

  bucket = aws_s3_bucket.loki[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "loki" {
  count = var.cloud_provider == "aws" && var.loki.enabled ? 1 : 0

  bucket = aws_s3_bucket.loki[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# --------------------------------
# Mimir S3 Bucket
# --------------------------------

resource "aws_s3_bucket" "mimir" {
  count = var.cloud_provider == "aws" && var.mimir.enabled ? 1 : 0

  bucket = local.mimir_s3_bucket

  tags = merge(
    local.common_tags,
    {
      Component = "mimir"
      Purpose   = "metrics-storage"
    }
  )
}

resource "aws_s3_bucket_versioning" "mimir" {
  count = var.cloud_provider == "aws" && var.mimir.enabled ? 1 : 0

  bucket = aws_s3_bucket.mimir[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mimir" {
  count = var.cloud_provider == "aws" && var.mimir.enabled ? 1 : 0

  bucket = aws_s3_bucket.mimir[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# --------------------------------
# Tempo S3 Bucket
# --------------------------------

resource "aws_s3_bucket" "tempo" {
  count = var.cloud_provider == "aws" && var.tempo.enabled ? 1 : 0

  bucket = local.tempo_s3_bucket

  tags = merge(
    local.common_tags,
    {
      Component = "tempo"
      Purpose   = "tracing-storage"
    }
  )
}

resource "aws_s3_bucket_versioning" "tempo" {
  count = var.cloud_provider == "aws" && var.tempo.enabled ? 1 : 0

  bucket = aws_s3_bucket.tempo[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tempo" {
  count = var.cloud_provider == "aws" && var.tempo.enabled ? 1 : 0

  bucket = aws_s3_bucket.tempo[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# --------------------------------
# Pyroscope S3 Bucket
# --------------------------------

resource "aws_s3_bucket" "pyroscope" {
  count = var.cloud_provider == "aws" && var.pyroscope.enabled ? 1 : 0

  bucket = local.pyroscope_s3_bucket

  tags = merge(
    local.common_tags,
    {
      Component = "pyroscope"
      Purpose   = "profiling-storage"
    }
  )
}

resource "aws_s3_bucket_versioning" "pyroscope" {
  count = var.cloud_provider == "aws" && var.pyroscope.enabled ? 1 : 0

  bucket = aws_s3_bucket.pyroscope[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pyroscope" {
  count = var.cloud_provider == "aws" && var.pyroscope.enabled ? 1 : 0

  bucket = aws_s3_bucket.pyroscope[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
