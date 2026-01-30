output "oidc_provider_arn" {
  description = "ARN of the created IAM OIDC provider."
  value       = aws_iam_openid_connect_provider.discovery.arn
}

output "role_arn" {
  description = "ARN of the IAM role that can be assumed via OIDC."
  value       = aws_iam_role.discovery.arn
}

output "role_name" {
  description = "Name of the IAM role."
  value       = aws_iam_role.discovery.name
}
