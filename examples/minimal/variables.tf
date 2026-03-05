variable "cluster_name" {
  description = "Name of the existing EKS cluster"
  type        = string
}

variable "region" {
  description = "AWS region of the EKS cluster"
  type        = string
}

variable "harbor_url" {
  description = "Harbor registry URL (e.g., registry.dev.weaura.ai/weaura-vendorized)"
  type        = string
}

variable "harbor_username" {
  description = "Harbor robot account username"
  type        = string
}

variable "harbor_password" {
  description = "Harbor robot account password"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}
