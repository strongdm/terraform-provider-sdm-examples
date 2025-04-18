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
# Create a manual Approval Workflow 
####################################
# Creates a manual approval workflow with approval steps in the order specified.
# - quantifier specifies whether "any" or "all" the approvers specified need to grant approval for that approal step
# - skip_after specifies a timeout after which the approval step will be auto-approved
# - roles designated as approvers in each approval step allow users in that role to grant approval for that approval step
# - users designated as approvers in each approval step allows that user to grant approval for that approval step
resource "sdm_approval_workflow" "manual_approval_workflow" {
    name = "manual approval workflow example"
    approval_mode = "manual"
    approval_step {
        quantifier = "any"
        skip_after = "1h0m0s"
        approvers {
            account_id = sdm_account.approver_user_manual_workflow.id
        }
    }
    approval_step {
        quantifier = "all"
        skip_after = "0s"
        approvers {
            role_id = sdm_role.approver_role_manual_workflow.id
        }
        approvers {
            account_id = sdm_account.approver2_user_manual_workflow.id
        }
    }
}

####################################
# Create a User 
####################################
resource "sdm_account" "approver_user_manual_workflow" {
    user {
        first_name = "Test"
        last_name = "Approver"
        email = "test.approver@example.com"
    }
}

resource "sdm_account" "approver2_user_manual_workflow" {
    user {
        first_name = "Test2"
        last_name = "Approver2"
        email = "test.approver2@example.com"
    }
}

####################################
# Create a Role 
####################################
resource "sdm_role" "approver_role_manual_workflow" {
  name = "example-role for manual workflow"
}
