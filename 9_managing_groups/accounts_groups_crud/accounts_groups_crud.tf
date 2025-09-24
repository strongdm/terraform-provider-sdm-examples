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

####################################
# Create prerequisite accounts
####################################
resource "sdm_account" "security_lead" {
  user {
    first_name       = "Security"
    last_name        = "Lead"
    email            = "security.lead@example.com"
    permission_level = "multi-team-leader"
  }
}

resource "sdm_account" "admin_user" {
  user {
    first_name       = "Admin"
    last_name        = "User"
    email            = "admin.user@example.com"
    permission_level = "database-admin"
  }
}

resource "sdm_account" "devops_engineer" {
  user {
    first_name       = "DevOps"
    last_name        = "Engineer"
    email            = "devops.engineer@example.com"
    permission_level = "user"
  }
}

resource "sdm_account" "qa_analyst" {
  user {
    first_name       = "QA"
    last_name        = "Analyst"
    email            = "qa.analyst@example.com"
    permission_level = "user"
  }
}

####################################
# Create prerequisite groups
####################################
resource "sdm_group" "security_team" {
  name = "Security Team"
}

resource "sdm_group" "administrators" {
  name = "Administrators"
}

resource "sdm_group" "devops_team" {
  name = "DevOps Team"
}

resource "sdm_group" "qa_team" {
  name = "QA Team"
}

####################################
# AccountsGroups CRUD Operations
####################################

# CREATE: Link accounts (users) to groups
resource "sdm_account_group" "security_lead_to_security_team" {
  account_id = sdm_account.security_lead.id
  group_id   = sdm_group.security_team.id
}

resource "sdm_account_group" "admin_user_to_administrators" {
  account_id = sdm_account.admin_user.id
  group_id   = sdm_group.administrators.id
}

resource "sdm_account_group" "devops_engineer_to_devops_team" {
  account_id = sdm_account.devops_engineer.id
  group_id   = sdm_group.devops_team.id
}

resource "sdm_account_group" "qa_analyst_to_qa_team" {
  account_id = sdm_account.qa_analyst.id
  group_id   = sdm_group.qa_team.id
}

# Example: User can be in multiple groups
resource "sdm_account_group" "security_lead_to_administrators" {
  account_id = sdm_account.security_lead.id
  group_id   = sdm_group.administrators.id
}

# READ: Data sources to query existing account-group relationships
data "sdm_account_group" "existing_account_groups" {
  depends_on = [
    sdm_account_group.security_lead_to_security_team,
    sdm_account_group.admin_user_to_administrators,
    sdm_account_group.devops_engineer_to_devops_team,
    sdm_account_group.qa_analyst_to_qa_team,
    sdm_account_group.security_lead_to_administrators
  ]
}

####################################
# Output Information (READ operations)
####################################
output "created_accounts" {
  value = {
    security_lead = {
      id    = sdm_account.security_lead.id
      email = sdm_account.security_lead.user[0].email
    }
    admin_user = {
      id    = sdm_account.admin_user.id
      email = sdm_account.admin_user.user[0].email
    }
    devops_engineer = {
      id    = sdm_account.devops_engineer.id
      email = sdm_account.devops_engineer.user[0].email
    }
    qa_analyst = {
      id    = sdm_account.qa_analyst.id
      email = sdm_account.qa_analyst.user[0].email
    }
  }
  description = "Details of created accounts"
}

output "created_groups" {
  value = {
    security_team = {
      id   = sdm_group.security_team.id
      name = sdm_group.security_team.name
    }
    administrators = {
      id   = sdm_group.administrators.id
      name = sdm_group.administrators.name
    }
    devops_team = {
      id   = sdm_group.devops_team.id
      name = sdm_group.devops_team.name
    }
    qa_team = {
      id   = sdm_group.qa_team.id
      name = sdm_group.qa_team.name
    }
  }
  description = "Details of created groups"
}

output "account_group_relationships" {
  value = {
    security_lead_groups = [
      sdm_account_group.security_lead_to_security_team.id,
      sdm_account_group.security_lead_to_administrators.id
    ]
    admin_user_groups = [
      sdm_account_group.admin_user_to_administrators.id
    ]
    devops_engineer_groups = [
      sdm_account_group.devops_engineer_to_devops_team.id
    ]
    qa_analyst_groups = [
      sdm_account_group.qa_analyst_to_qa_team.id
    ]
  }
  description = "Account-Group relationship IDs"
}

output "all_account_groups_count" {
  value       = length(data.sdm_account_group.existing_account_groups.accounts_groups)
  description = "Total number of account-group relationships"
}

output "membership_summary" {
  value = {
    "Security Team"  = ["Security Lead"]
    "Administrators" = ["Admin User", "Security Lead"]
    "DevOps Team"    = ["DevOps Engineer"]
    "QA Team"        = ["QA Analyst"]
  }
  description = "Summary of group memberships"
}