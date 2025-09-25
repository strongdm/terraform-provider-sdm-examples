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
# Groups CRUD Operations
####################################

# CREATE: Create new groups with various configurations
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

# READ: Data sources to query existing groups
data "sdm_group" "existing_groups" {
  depends_on = [
    sdm_group.security_team,
    sdm_group.administrators,
    sdm_group.devops_team,
    sdm_group.qa_team
  ]
  name = "*"
}

####################################
# Output Group Information (READ operations)
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

output "all_groups_count" {
  value = length(data.sdm_group.existing_groups.groups)
  description = "Total number of groups in the organization"
}

output "groups_list" {
  value = [for group in data.sdm_group.existing_groups.groups : {
    id   = group.id
    name = group.name
  }]
  description = "List of all groups with their IDs and names"
}