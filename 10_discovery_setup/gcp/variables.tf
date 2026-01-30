variable "sdm_website_subdomain" {
  description = "Your StrongDM organization's website subdomain. This is the Web Domain from this page: https://app.strongdm.com/app/settings/account."
  type        = string
}

variable "project_ids" {
  description = "List of GCP project IDs to scan for discoverable resources"
  type        = list(string)
}

variable "services" {
  description = "List of GCP services to scan. Valid values: GKE, CloudSQL, ComputeEngine, AlloyDB, Memorystore"
  type        = list(string)
  default     = ["GKE", "SQL", "GCE"]
}

variable "connector_name" {
  description = "Name for the StrongDM discovery connector"
  type        = string
  default     = "gcp-discovery-connector"
}

variable "pool_id" {
  description = "ID for the Workload Identity Pool"
  type        = string
  default     = "strongdm-discovery-pool"
}

variable "provider_id" {
  description = "ID for the Workload Identity Pool Provider"
  type        = string
  default     = "strongdm-discovery-provider"
}

variable "scan_period" {
  description = "How often to scan for resources. Valid values: TwiceDaily, Daily"
  type        = string
  default     = "Daily"
}
