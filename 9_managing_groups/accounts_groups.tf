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
# Create Users
####################################
resource "sdm_account" "security_lead" {
  user {
    first_name = "Security"
    last_name  = "Lead"
    email      = "security.lead@example.com"
    permission_level = "team-leader"
  }
}

resource "sdm_account" "admin_user" {
  user {
    first_name = "Admin"
    last_name  = "User"
    email      = "admin.user@example.com"
    permission_level = "database-admin"
  }
}

resource "sdm_account" "devops_engineer" {
  user {
    first_name = "DevOps"
    last_name  = "Engineer"
    email      = "devops.engineer@example.com"
    permission_level = "user"
  }
}

resource "sdm_account" "qa_analyst" {
  user {
    first_name = "QA"
    last_name  = "Analyst"
    email      = "qa.analyst@example.com"
    permission_level = "user"
  }
}

####################################
# Create Groups
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
# Create Account-Group Relationships
####################################
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

####################################
# Output Information
####################################
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