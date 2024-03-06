# Copyright 2024 strongDM Inc
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
# Create a manual Approval Workflow 
####################################
resource "sdm_approval_workflow" "manual_approval_workflow" {
    name = "manual approval workflow example"
    approval_mode = "manual"
}

####################################
# Create a manual Approval Workflow Step
####################################
resource "sdm_approval_workflow_step" "manual_approval_workflow_step" {
    approval_flow_id = sdm_approval_workflow.manual_approval_workflow.id
}

####################################
# Create a User 
####################################
# This user will be the approver of the manual Approval Workflow. 
resource "sdm_account" "approver_user_manual_workflow" {
    user {
        first_name = "Test"
        last_name = "Approver"
        email = "test.approver@example.com"
        suspended = false
    }
}

####################################
# Create an Approval Workflow Approver (account)
####################################
# Approval workflow approvers are the users or roles who can manually respond to a request.
resource "sdm_approval_workflow_approver" "approval_workflow_approver_account_example" {
    approval_flow_id = sdm_approval_workflow.manual_approval_workflow.id
    approval_step_id = sdm_approval_workflow_step.manual_approval_workflow_step.id
    account_id = sdm_account.approver_user_manual_workflow.id
}

####################################
# Create a Role 
####################################
# This role will be the approver of the manual Approval Workflow. 
resource "sdm_role" "approver_role_manual_workflow" {
  name = "example-role for manual workflow"
}

####################################
# Create an Approval Workflow Approver (role)
####################################
# Approval workflow approvers are the users or roles who can manually respond to a request.
resource "sdm_approval_workflow_approver" "approval_workflow_approver_account_example" {
    approval_flow_id = sdm_approval_workflow.manual_approval_workflow.id
    approval_step_id = sdm_approval_workflow_step.manual_approval_workflow_step.id
    role_id = sdm_role.approver_role_manual_workflow.id
}

# At this point, the approval workflow will be created and a step with two approvers assigned.