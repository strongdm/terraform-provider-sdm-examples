# Copyright 2023 strongDM Inc
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
# Create a Resource 
####################################
# This resource will be assigned to the workflow via access rules.
resource "sdm_resource" "redis-test-auto-workflow" {
  redis {
    name     = "redis example for auto workflow"
    hostname = "example.com"
    password = "example"
    port     = 6379
    tags     = { region = "us-east" }
  }
}

####################################
# Create an automatic approval workflow
####################################
resource "sdm_approval_workflow" "auto_grant" {
  name = "Auto Grant Example"
  approval_mode = "automatic"
}

####################################
# Create an auto grant Workflow 
####################################
resource "sdm_workflow" "auto-grant-workflow" {
    name = "auto grant workflow example"
    approval_flow_id = sdm_approval_workflow.auto_grant.id
    enabled = true
    access_rules = jsonencode([
    # Grant access to all Redis Datasources in us-east region
    {
      "type" : "redis",
      "tags" : { "region" : "us-east" }
    }
  ])
}

####################################
# Create a Role 
####################################
# This role will grant users with this role access to the resources managed by this workflow.
resource "sdm_role" "example-role-auto-grant-workflow" {
  name = "example-role for auto-grant workflow"
}

####################################
# Create a Workflow Role
####################################
# Workflow Roles are the roles that, when assigned to a workflow, grant access to this
# workflow to the users who are also assigned the role.
resource "sdm_workflow_role" "workflow-role-auto-grant-workflow" {
  workflow_id = sdm_workflow.auto-grant-workflow.id
  role_id = sdm_role.example-role-auto-grant-workflow.id
}