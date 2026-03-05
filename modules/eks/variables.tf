variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.35"
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster and node groups"
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Whether the EKS API server endpoint is publicly accessible"
  type        = bool
  default     = true
}

variable "enable_auto_mode" {
  description = "Enable EKS Auto Mode (disables traditional managed node groups)"
  type        = bool
  default     = false
}

variable "auto_mode_node_pools" {
  description = "List of Auto Mode node pools to enable"
  type        = list(string)
  default     = ["general-purpose", "system"]
}

variable "enable_pod_identity_agent" {
  description = "Enable the EKS Pod Identity Agent addon"
  type        = bool
  default     = true
}

variable "node_group_config" {
  description = "Configuration for the default managed node group"
  type = object({
    desired_size   = optional(number, 3)
    max_size       = optional(number, 5)
    min_size       = optional(number, 1)
    instance_types = optional(list(string), ["t3.xlarge"])
    disk_size      = optional(number, 50)
  })
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
