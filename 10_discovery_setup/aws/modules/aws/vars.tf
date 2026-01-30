variable "issuer_url" {
  description = "The StrongDM Issuer URL. For example: https://app.strongdm.com/oidc/foobar-org where foobar-org is your Organization's subdomain in StrongDM"
  type        = string
}

variable "connector_ids" {
  description = "The connector IDs to allow role assumption for. If empty, all connectors for the org will be allowed to assume the role."
  type        = set(string)
  default     = []
}

variable "role_name" {
  description = "Name of the IAM role to create that can be assumed via OIDC."
  type        = string
  default     = "StrongDMDiscoveryReadOnly"
}
