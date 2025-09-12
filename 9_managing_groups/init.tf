# Copyright 2025 strongDM Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

terraform {
  required_providers {
    sdm = {
      version = "~> 15"
      source  = "strongdm/sdm"
    }
  }
}

# StrongDM Provider Configuration
# Two configuration modes are supported:
#
# Configuration Mode 1: Terraform variables (RECOMMENDED)
# - Use this for production environments and CI/CD pipelines
# - Variables can be provided via:
#   * Environment variables: TF_VAR_sdm_api_access_key, TF_VAR_sdm_api_secret_key
#   * Command line: -var="sdm_api_access_key=YOUR_KEY"
#   * terraform.tfvars file (not recommended for secrets)
#   * Variable files: -var-file="secret.tfvars"
#
# Configuration Mode 2: Direct hardcoded values (NOT RECOMMENDED)
# - Only use for testing/debugging in secure environments
# - Never commit API keys to version control

# Configuration Mode 1: Terraform variables (RECOMMENDED)
provider "sdm" {
  api_access_key = var.sdm_api_access_key
  api_secret_key = var.sdm_api_secret_key
  # host = var.sdm_host # Uncomment if different than the default (app.strongdm.com) is required
}

variable "sdm_api_access_key" {
  type = string
}

variable "sdm_api_secret_key" {
  type = string
}

# variable "sdm_host" {
#   type = string
# }

# Configuration Mode 2: Direct hardcoded values (NOT RECOMMENDED)
# WARNING: Only use this for local testing/debugging. Never commit real API keys!
# provider "sdm" {
#   api_access_key = "your-access-key-here"
#   api_secret_key = "your-secret-key-here"
# }