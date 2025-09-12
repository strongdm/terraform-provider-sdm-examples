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

# Data Source Examples for Groups and Roles
# 
# This example demonstrates how to use Terraform data sources to reference
# existing groups and roles instead of creating new ones.
# 
# Use cases:
# - Reference existing groups/roles created outside of Terraform
# - Build upon existing organizational structure  
# - Avoid duplicating resources across different Terraform configurations
# - Create relationships with pre-existing resources

####################################
# Fetch Existing Groups
####################################

# Example: Reference an existing group by name
# This is useful when you have groups created manually or by other Terraform configs
data "sdm_group" "existing_security_team" {
  name = "Security Team"
}

# Example: Reference an existing group by ID (if known)
# data "sdm_group" "existing_admin_group" {
#   id = "g-1234567890abcdef"
# }

####################################
# Fetch Existing Roles  
####################################

# Example: Reference an existing role by name
data "sdm_role" "existing_database_role" {
  name = "Database Access"
}

# Example: Reference an existing role by ID (if known) 
# data "sdm_role" "existing_prod_role" {
#   id = "r-fedcba0987654321"
# }

####################################
# Create New Resources Using Existing Ones
####################################

# Create a new user
resource "sdm_account" "new_developer" {
  user {
    first_name       = "New"
    last_name        = "Developer"
    email            = "new.developer@company.com"
    permission_level = "user"
  }
}

# Add the new user to an existing group (fetched via data source)
resource "sdm_account_group" "new_dev_to_existing_security_team" {
  account_id = sdm_account.new_developer.id
  group_id   = data.sdm_group.existing_security_team.id
}

# Assign an existing role (fetched via data source) to an existing group
resource "sdm_group_role" "existing_group_to_existing_role" {
  group_id = data.sdm_group.existing_security_team.id
  role_id  = data.sdm_role.existing_database_role.id
}

####################################
# Mixed Approach: New and Existing Resources
####################################

# Create a new group
resource "sdm_group" "new_qa_team" {
  name = "QA Team"
}

# Assign existing role to new group
resource "sdm_group_role" "new_group_to_existing_role" {
  group_id = sdm_group.new_qa_team.id
  role_id  = data.sdm_role.existing_database_role.id
}

####################################
# Outputs Showing Data Source Values
####################################

output "existing_group_info" {
  value = {
    id   = data.sdm_group.existing_security_team.id
    name = data.sdm_group.existing_security_team.name
  }
  description = "Information about the existing Security Team group"
}

output "existing_role_info" {
  value = {
    id   = data.sdm_role.existing_database_role.id
    name = data.sdm_role.existing_database_role.name
  }
  description = "Information about the existing Database Access role"
}

####################################
# Best Practices with Data Sources
####################################

# Use locals to make data source references more readable
locals {
  # Reference existing groups
  security_team_id = data.sdm_group.existing_security_team.id
  
  # Reference existing roles  
  database_role_id = data.sdm_role.existing_database_role.id
}

# Example using locals for cleaner resource definitions
resource "sdm_account_group" "example_using_locals" {
  account_id = sdm_account.new_developer.id
  group_id   = local.security_team_id
}

####################################
# Data Source Benefits
####################################

output "data_source_benefits" {
  value = {
    "Avoid Resource Duplication" = "Reference existing resources instead of recreating them"
    "Cross-Config Integration" = "Connect Terraform configurations that manage different aspects"
    "Organizational Alignment" = "Work with existing group/role structures in your organization"
    "Reduced Drift" = "Ensure Terraform state matches actual resources in StrongDM"
    "Incremental Adoption" = "Gradually adopt Terraform without recreating everything"
  }
  description = "Benefits of using data sources for groups and roles"
}