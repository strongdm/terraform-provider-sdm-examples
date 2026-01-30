output "connector_id" {
  description = "The ID of the StrongDM discovery connector"
  value       = sdm_connector.gcp_discovery.id
}

output "issuer_url" {
  description = "The OIDC issuer URL used for federation"
  value       = local.issuer_url
}

output "workload_identity_pool_id" {
  description = "The Workload Identity Pool ID"
  value       = google_iam_workload_identity_pool.sdm.workload_identity_pool_id
}

output "workload_identity_pool_provider_id" {
  description = "The Workload Identity Pool Provider ID"
  value       = google_iam_workload_identity_pool_provider.sdm_oidc.workload_identity_pool_provider_id
}

output "principal_subject" {
  description = "The principal subject used for IAM bindings"
  value       = local.principal_subject
}
