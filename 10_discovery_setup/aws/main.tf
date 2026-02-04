terraform {
  required_version = ">= 1.3.0"

  required_providers {
    sdm = {
      source  = "strongdm/sdm"
      version = "~> 16"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "sdm_org_url_info" "org" {
}

# Create the StrongDM discovery connector for AWS
resource "sdm_connector" "aws_discovery" {
  aws {
    name        = var.connector_name
    description = "Discovers resources across AWS accounts: ${join(", ", var.account_ids)}"

    scan_period = var.scan_period
    role_name   = var.role_name
    account_ids = var.account_ids
    services    = var.services
  }
}

####
#### AWS Provider Configuration
####
#### For each AWS account you want to scan, you need to:
#### 1. Define a provider alias for that account
#### 2. Call the sdm_discovery_aws module with that provider
####
#### Authentication options:
####   - AWS CLI profiles (profile = "profile_name")
####   - Assume role (assume_role { role_arn = "..." })
####   - Environment variables (for single account)
####

# Example: Configure provider for each account
# Uncomment and duplicate for each account in var.account_ids

# provider "aws" {
#   alias = "account_1"
#   # Option 1: Use an AWS CLI profile
#   # profile = "my-profile"
#
#   # Option 2: Assume a role (cross-account access)
#   # assume_role {
#   #   role_arn = "arn:aws:iam::ACCOUNT_ID:role/TerraformExecutionRole"
#   # }
# }

# Default provider - used when no alias is specified
# Configure this for your primary/management account
provider "aws" {
  region = var.region
  # Authentication is typically handled via:
  # - AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables
  # - AWS CLI profile (~/.aws/credentials)
  # - IAM role (when running on EC2/ECS/Lambda)
}

provider "sdm" {
  # api_access_key and api_secret_key read from environment variables
}

# Create IAM resources in the default account
# Duplicate this block for each account, using different provider aliases
module "sdm_discovery_aws" {
  source = "./modules/aws"

  # Uncomment to use a specific provider alias:
  # providers = {
  #   aws = aws.account_1
  # }

  issuer_url    = data.sdm_org_url_info.org.oidc_issuer_url
  connector_ids = toset([sdm_connector.aws_discovery.id])
  role_name     = var.role_name
}
