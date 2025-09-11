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

####################################
# Create Roles
####################################
resource "sdm_role" "database_access" {
  name = "Database Access Role"
}

resource "sdm_role" "production_access" {
  name = "Production Access Role"
}

resource "sdm_role" "security_audit" {
  name = "Security Audit Role"
}

resource "sdm_role" "admin_access" {
  name = "Admin Access Role"
}

####################################
# Create Group-Role Relationships
####################################
# Security Team gets security audit access and production access
resource "sdm_group_role" "security_team_to_security_audit" {
  group_id = sdm_group.security_team.id
  role_id  = sdm_role.security_audit.id
}

resource "sdm_group_role" "security_team_to_production_access" {
  group_id = sdm_group.security_team.id
  role_id  = sdm_role.production_access.id
}

# Administrators get admin access and database access
resource "sdm_group_role" "administrators_to_admin_access" {
  group_id = sdm_group.administrators.id
  role_id  = sdm_role.admin_access.id
}

resource "sdm_group_role" "administrators_to_database_access" {
  group_id = sdm_group.administrators.id
  role_id  = sdm_role.database_access.id
}

# DevOps Team gets production access and database access
resource "sdm_group_role" "devops_team_to_production_access" {
  group_id = sdm_group.devops_team.id
  role_id  = sdm_role.production_access.id
}

resource "sdm_group_role" "devops_team_to_database_access" {
  group_id = sdm_group.devops_team.id
  role_id  = sdm_role.database_access.id
}

####################################
# Output Information
####################################
output "group_role_relationships" {
  value = {
    security_team_roles = [
      sdm_group_role.security_team_to_security_audit.id,
      sdm_group_role.security_team_to_production_access.id
    ]
    administrators_roles = [
      sdm_group_role.administrators_to_admin_access.id,
      sdm_group_role.administrators_to_database_access.id
    ]
    devops_team_roles = [
      sdm_group_role.devops_team_to_production_access.id,
      sdm_group_role.devops_team_to_database_access.id
    ]
  }
  description = "Group-Role relationship IDs"
}

output "role_assignments_summary" {
  value = {
    "Security Audit Role" = ["Security Team"]
    "Production Access Role" = ["Security Team", "DevOps Team"]
    "Database Access Role" = ["Administrators", "DevOps Team"]
    "Admin Access Role" = ["Administrators"]
  }
  description = "Summary of which groups have access to which roles"
}