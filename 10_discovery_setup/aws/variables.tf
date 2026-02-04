variable "account_ids" {
  description = "List of AWS account IDs to scan for discoverable resources"
  type        = list(string)
}

variable "region" {
  description = "AWS Region for your AWS credentials"
  type        = string
}

variable "services" {
  description = "List of AWS services to scan. Currently supported services: RDS, EC2, EKS"
  type        = list(string)
  default     = ["RDS", "EC2", "EKS"]
}

variable "connector_name" {
  description = "Name for the StrongDM discovery connector"
  type        = string
  default     = "aws-discovery-connector"
}

variable "role_name" {
  description = "Name of the IAM role to create in each account that the connector will assume"
  type        = string
  default     = "StrongDMDiscoveryReadOnly"
}

variable "scan_period" {
  description = "How often to scan for resources. Valid values: TwiceDaily, Daily"
  type        = string
  default     = "Daily"
}
