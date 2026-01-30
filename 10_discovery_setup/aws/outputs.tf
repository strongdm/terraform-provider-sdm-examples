output "connector_id" {
  description = "The ID of the StrongDM discovery connector"
  value       = sdm_connector.aws_discovery.id
}

output "issuer_url" {
  description = "The OIDC issuer URL used for federation"
  value       = local.issuer_url
}

output "iam_role_arn" {
  description = "ARN of the IAM role created for discovery"
  value       = module.sdm_discovery_aws.role_arn
}

output "iam_role_name" {
  description = "Name of the IAM role created for discovery"
  value       = module.sdm_discovery_aws.role_name
}
