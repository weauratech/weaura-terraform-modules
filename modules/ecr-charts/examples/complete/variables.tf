# ============================================================
# Example Variables
# ============================================================

variable "region" {
  description = "AWS region for ECR repositories"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
