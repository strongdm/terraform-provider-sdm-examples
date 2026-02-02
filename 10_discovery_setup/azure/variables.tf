variable "sdm_website_subdomain" {
  description = "Your StrongDM organization's website subdomain. This is the Web Domain from this page: https://app.strongdm.com/app/settings/account."
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

variable "subscription_ids" {
  description = "List of Azure subscription IDs to scan for discoverable resources"
  type        = list(string)
}

variable "services" {
  description = "List of Azure services to scan. Currently supported: AzureVM, AzureSQL, AKS"
  type        = list(string)
  default     = ["AzureVM", "AzureSQL", "AKS"]
}

variable "connector_name" {
  description = "Name for the StrongDM discovery connector"
  type        = string
  default     = "azure-discovery-connector"
}

variable "application_name" {
  description = "Name for the Azure AD application used for discovery"
  type        = string
  default     = "StrongDM Discovery"
}

variable "scan_period" {
  description = "How often to scan for resources. Valid values: TwiceDaily, Daily"
  type        = string
  default     = "Daily"
}
