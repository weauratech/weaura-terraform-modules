# ============================================================
# Output Values
# ============================================================

output "repository_urls" {
  description = "Map of chart names to their ECR repository URLs"
  value = {
    for k, v in aws_ecr_repository.charts : k => v.repository_url
  }
}

output "repository_arns" {
  description = "Map of chart names to their ECR repository ARNs"
  value = {
    for k, v in aws_ecr_repository.charts : k => v.arn
  }
}

output "registry_id" {
  description = "ECR registry ID (AWS account ID)"
  value       = try(values(aws_ecr_repository.charts)[0].registry_id, null)
}

output "oci_urls" {
  description = "Map of chart names to their full OCI URLs for Helm"
  value = {
    for k, v in aws_ecr_repository.charts : k => "oci://${v.repository_url}"
  }
}

output "pull_commands" {
  description = "Map of chart names to example Helm pull commands"
  value = {
    for k, v in aws_ecr_repository.charts : k => "helm pull oci://${v.repository_url} --version VERSION"
  }
}
