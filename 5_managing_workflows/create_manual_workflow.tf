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
resource "sdm_resource" "redis-test-manual-workflow" {
  redis {
    name     = "redis example for manual workflow"
    hostname = "example.com"
    password = "example"
    port     = 6379
    tags     = { region = "us-east" }
  }
}


####################################
# Create a manual approval approval flow 
####################################
resource "sdm_approval_workflow" "manual_approval" {
  name = "Manual Approval Example"
  approval_mode = "manual"
  approval_step {
    quantifier = "any"
    skip_after = "2h0m0s"
    approvers {
      reference = "manager-of-requester"
    }
  }
}

####################################
# Create a manual approval Workflow 
####################################
# This workflow will be disabled initially.
resource "sdm_workflow" "manual-approval-workflow" {
    name = "manual approval workflow example"
    approval_flow_id = sdm_approval_workflow.manual_approval.id
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
resource "sdm_role" "example-role-manual-workflow" {
  name = "example-role for manual workflow"
}

####################################
# Create a Workflow Role
####################################
# Workflow Roles are the roles that, when assigned to a workflow, grant access to this
# workflow to the users who are also assigned the role.
resource "sdm_workflow_role" "workflow-role-manual-workflow" {
  workflow_id = sdm_workflow.manual-approval-workflow.id
  role_id = sdm_role.example-role-manual-workflow.id
}

# At this point, the workflow will be created and an approver assigned, but the
# workflow will not be enabled. A subsequent update to the workflow is required
# to enable it.