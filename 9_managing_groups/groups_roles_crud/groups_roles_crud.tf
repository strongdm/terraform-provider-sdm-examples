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
# Create prerequisite roles
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

resource "sdm_role" "qa_testing" {
  name = "QA Testing Role"
}

####################################
# GroupsRoles CRUD Operations
####################################

# CREATE: Link groups to roles
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

# QA Team gets qa testing role
resource "sdm_group_role" "qa_team_to_qa_testing" {
  group_id = sdm_group.qa_team.id
  role_id  = sdm_role.qa_testing.id
}

# READ: Data sources to query existing group-role relationships
data "sdm_group_role" "existing_group_roles" {
  depends_on = [
    sdm_group_role.security_team_to_security_audit,
    sdm_group_role.security_team_to_production_access,
    sdm_group_role.administrators_to_admin_access,
    sdm_group_role.administrators_to_database_access,
    sdm_group_role.devops_team_to_production_access,
    sdm_group_role.devops_team_to_database_access,
    sdm_group_role.qa_team_to_qa_testing
  ]
}

####################################
# Output Information (READ operations)
####################################
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

output "created_roles" {
  value = {
    database_access = {
      id   = sdm_role.database_access.id
      name = sdm_role.database_access.name
    }
    production_access = {
      id   = sdm_role.production_access.id
      name = sdm_role.production_access.name
    }
    security_audit = {
      id   = sdm_role.security_audit.id
      name = sdm_role.security_audit.name
    }
    admin_access = {
      id   = sdm_role.admin_access.id
      name = sdm_role.admin_access.name
    }
    qa_testing = {
      id   = sdm_role.qa_testing.id
      name = sdm_role.qa_testing.name
    }
  }
  description = "Details of created roles"
}

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
    qa_team_roles = [
      sdm_group_role.qa_team_to_qa_testing.id
    ]
  }
  description = "Group-Role relationship IDs"
}

output "all_group_roles_count" {
  value = length(data.sdm_group_role.existing_group_roles.groups_roles)
  description = "Total number of group-role relationships"
}

output "role_assignments_summary" {
  value = {
    "Security Audit Role" = ["Security Team"]
    "Production Access Role" = ["Security Team", "DevOps Team"]
    "Database Access Role" = ["Administrators", "DevOps Team"]
    "Admin Access Role" = ["Administrators"]
    "QA Testing Role" = ["QA Team"]
  }
  description = "Summary of which groups have access to which roles"
}

output "group_permissions_summary" {
  value = {
    "Security Team" = ["Security Audit Role", "Production Access Role"]
    "Administrators" = ["Admin Access Role", "Database Access Role"]
    "DevOps Team" = ["Production Access Role", "Database Access Role"]
    "QA Team" = ["QA Testing Role"]
  }
  description = "Summary of which roles each group has"
}