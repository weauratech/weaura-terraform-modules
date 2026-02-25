# ============================================================
# Input Variables
# ============================================================

# --------------------------------
# Required Variables
# --------------------------------

variable "charts" {
  description = "Map of Helm charts to create ECR repositories for"
  type = map(object({
    name        = string
    description = optional(string, "")
  }))

  validation {
    condition     = length(var.charts) > 0
    error_message = "At least one chart must be specified."
  }
}

# --------------------------------
# Optional Variables
# --------------------------------

variable "repository_prefix" {
  description = "Prefix for ECR repository names (e.g., 'weaura-vendorized/charts')"
  type        = string
  default     = "weaura-vendorized/charts"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for repositories (AES256 or KMS)"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be either 'AES256' or 'KMS'."
  }
}

variable "kms_key_arn" {
  description = "ARN of KMS key for repository encryption (required if encryption_type is KMS)"
  type        = string
  default     = null
}

variable "lifecycle_policy_rules" {
  description = "Lifecycle policy rules to keep only N recent images"
  type = object({
    max_image_count = number
  })
  default = {
    max_image_count = 10
  }
}

variable "cross_account_pull_principals" {
  description = "List of AWS account IDs or ARNs allowed to pull images (use ['*'] for public access within AWS)"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
