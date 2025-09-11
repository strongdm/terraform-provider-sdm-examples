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

resource "sdm_group" "qa_team" {
  name = "QA Team"
}

####################################
# Output Group Information
####################################
output "security_team_id" {
  value = sdm_group.security_team.id
  description = "The ID of the Security Team group"
}

output "administrators_id" {
  value = sdm_group.administrators.id
  description = "The ID of the Administrators group"
}

output "devops_team_id" {
  value = sdm_group.devops_team.id
  description = "The ID of the DevOps Team group"
}

output "qa_team_id" {
  value = sdm_group.qa_team.id
  description = "The ID of the QA Team group"
}