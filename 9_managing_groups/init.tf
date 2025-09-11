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
      source = "strongdm/sdm"
    }
  }
}

# StrongDM Provider Configuration
# Two configuration modes are supported:
# 1) Variables passed via command line, environment variables or another form of Terraform configuration
# 2) Variables passed directly in the configuration

# Configuration Mode 1: Terraform variables (preferred for production)
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

# Configuration Mode 2: Direct configuration (mainly used for testing/debugging)
# provider "sdm" {
#   api_access_key = "{{.AccessKey}}"
#   api_secret_key = "{{.SecretKey}}"
# }