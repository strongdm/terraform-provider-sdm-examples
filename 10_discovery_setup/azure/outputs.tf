output "connector_id" {
  description = "The ID of the StrongDM discovery connector"
  value       = sdm_connector.azure_discovery.id
}

output "issuer_url" {
  description = "The OIDC issuer URL used for federation"
  value       = local.issuer_url
}

output "client_id" {
  description = "The Azure AD application client ID (used for authentication configuration)"
  value       = azuread_application.strongdm_discovery.client_id
}

output "service_principal_object_id" {
  description = "The Azure AD service principal object ID (used internally for role assignments)"
  value       = azuread_service_principal.strongdm_discovery.object_id
}
