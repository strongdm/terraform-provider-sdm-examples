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

# Complete User → Group → Role Example
# This example demonstrates the full access control chain in StrongDM:
# 1. Create users (accounts)
# 2. Create groups for logical organization
# 3. Create roles that define resource access
# 4. Add users to groups (account-group relationships)
# 5. Assign roles to groups (group-role relationships)
# 
# Result: Users inherit access to resources through their group memberships

####################################
# 1. Create Users
####################################
resource "sdm_account" "junior_developer" {
  user {
    first_name       = "Junior"
    last_name        = "Developer"
    email            = "junior.dev@company.com"
    permission_level = "user"
  }
}

resource "sdm_account" "senior_developer" {
  user {
    first_name       = "Senior"
    last_name        = "Developer"
    email            = "senior.dev@company.com"
    permission_level = "user"
  }
}

resource "sdm_account" "team_lead" {
  user {
    first_name       = "Team"
    last_name        = "Lead"
    email            = "team.lead@company.com"
    permission_level = "team-leader"
  }
}

####################################
# 2. Create Groups (Logical Organization)
####################################
resource "sdm_group" "development_team" {
  name = "Development Team"
}

resource "sdm_group" "senior_developers" {
  name = "Senior Developers"
}

resource "sdm_group" "team_leads" {
  name = "Team Leads"
}

####################################
# 3. Create Roles (Define Resource Access)
####################################
resource "sdm_role" "development_database_access" {
  name = "Development Database Access"
}

resource "sdm_role" "staging_environment_access" {
  name = "Staging Environment Access"
}

resource "sdm_role" "production_read_only" {
  name = "Production Read-Only Access"
}

resource "sdm_role" "production_full_access" {
  name = "Production Full Access"
}

####################################
# 4. Add Users to Groups
####################################

# Junior Developer: Only in development team
resource "sdm_account_group" "junior_dev_to_development_team" {
  account_id = sdm_account.junior_developer.id
  group_id   = sdm_group.development_team.id
}

# Senior Developer: In both development team and senior developers group
resource "sdm_account_group" "senior_dev_to_development_team" {
  account_id = sdm_account.senior_developer.id
  group_id   = sdm_group.development_team.id
}

resource "sdm_account_group" "senior_dev_to_senior_developers" {
  account_id = sdm_account.senior_developer.id
  group_id   = sdm_group.senior_developers.id
}

# Team Lead: Member of all relevant groups
resource "sdm_account_group" "team_lead_to_development_team" {
  account_id = sdm_account.team_lead.id
  group_id   = sdm_group.development_team.id
}

resource "sdm_account_group" "team_lead_to_senior_developers" {
  account_id = sdm_account.team_lead.id
  group_id   = sdm_group.senior_developers.id
}

resource "sdm_account_group" "team_lead_to_team_leads" {
  account_id = sdm_account.team_lead.id
  group_id   = sdm_group.team_leads.id
}

####################################
# 5. Assign Roles to Groups
####################################

# Development Team: Access to development resources
resource "sdm_group_role" "dev_team_to_dev_database" {
  group_id = sdm_group.development_team.id
  role_id  = sdm_role.development_database_access.id
}

# Senior Developers: Additional staging access
resource "sdm_group_role" "senior_devs_to_staging" {
  group_id = sdm_group.senior_developers.id
  role_id  = sdm_role.staging_environment_access.id
}

resource "sdm_group_role" "senior_devs_to_prod_readonly" {
  group_id = sdm_group.senior_developers.id
  role_id  = sdm_role.production_read_only.id
}

# Team Leads: Full production access
resource "sdm_group_role" "team_leads_to_prod_full" {
  group_id = sdm_group.team_leads.id
  role_id  = sdm_role.production_full_access.id
}

####################################
# Output: Access Matrix Summary
####################################
output "user_access_matrix" {
  value = {
    "junior.dev@company.com" = {
      groups = ["Development Team"]
      roles = ["Development Database Access"]
      description = "Junior developer with basic development database access"
    }
    "senior.dev@company.com" = {
      groups = ["Development Team", "Senior Developers"]
      roles = ["Development Database Access", "Staging Environment Access", "Production Read-Only Access"]
      description = "Senior developer with dev, staging, and production read access"
    }
    "team.lead@company.com" = {
      groups = ["Development Team", "Senior Developers", "Team Leads"]
      roles = ["Development Database Access", "Staging Environment Access", "Production Read-Only Access", "Production Full Access"]
      description = "Team lead with full access across all environments"
    }
  }
  description = "Complete access matrix showing how users inherit permissions through groups"
}

output "access_inheritance_flow" {
  value = {
    step1 = "Users are created with basic account permissions"
    step2 = "Groups are created to organize users logically"
    step3 = "Roles are created to define resource access permissions"
    step4 = "Users are added to groups based on their responsibilities"
    step5 = "Roles are assigned to groups based on group needs"
    result = "Users inherit all role permissions from their group memberships"
  }
  description = "How access control works in StrongDM through the User → Group → Role model"
}

# Local values to demonstrate the relationships
locals {
  # Show which users belong to which groups
  user_group_memberships = {
    for account_group in [
      sdm_account_group.junior_dev_to_development_team,
      sdm_account_group.senior_dev_to_development_team,
      sdm_account_group.senior_dev_to_senior_developers,
      sdm_account_group.team_lead_to_development_team,
      sdm_account_group.team_lead_to_senior_developers,
      sdm_account_group.team_lead_to_team_leads
    ] : account_group.id => {
      account_id = account_group.account_id
      group_id   = account_group.group_id
    }
  }

  # Show which groups have which roles
  group_role_assignments = {
    for group_role in [
      sdm_group_role.dev_team_to_dev_database,
      sdm_group_role.senior_devs_to_staging,
      sdm_group_role.senior_devs_to_prod_readonly,
      sdm_group_role.team_leads_to_prod_full
    ] : group_role.id => {
      group_id = group_role.group_id
      role_id  = group_role.role_id
    }
  }
}

output "relationship_summary" {
  value = {
    total_users = 3
    total_groups = 3
    total_roles = 4
    total_account_group_relationships = 6
    total_group_role_relationships = 4
    user_group_memberships = local.user_group_memberships
    group_role_assignments = local.group_role_assignments
  }
  description = "Summary of all relationships created in this example"
}