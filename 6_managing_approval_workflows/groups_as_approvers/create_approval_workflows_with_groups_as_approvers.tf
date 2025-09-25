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

# Groups-Focused Approval Workflow Example
#
# This example demonstrates how to use GROUPS as approvers in approval workflows.
# For general approval workflow examples (including individual users, roles, etc.),
# see the ../6_managing_approval_workflows directory.
#
# This example specifically showcases:
# - Using groups as approvers in different approval steps
# - Combining group approvers with manager references
# - Different quantifier strategies with group-based approval

####################################
# Create Approver Groups
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
# Create Users for Group Membership
####################################
resource "sdm_account" "security_lead" {
  user {
    first_name = "Security"
    last_name  = "Lead"
    email      = "security.lead@example.com"
    permission_level = "multi-team-leader"
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

####################################
# Add Users to Groups
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

####################################
# Create Approval Workflow with Group Approvers
####################################
resource "sdm_approval_workflow" "group_based_approval_workflow" {
  name          = "Group-Based Approval Workflow"
  description   = "A workflow demonstrating group-based approvers"
  approval_mode = "manual"

  # Step 1: Any member of the Security Team can approve
  approval_step {
    quantifier = "any"
    skip_after = "2h0m0s"
    approvers {
      group_id = sdm_group.security_team.id
    }
  }

  # Step 2: All specified groups must approve
  approval_step {
    quantifier = "all" 
    skip_after = "24h0m0s"
    approvers {
      group_id = sdm_group.administrators.id
    }
    approvers {
      group_id = sdm_group.devops_team.id
    }
    approvers {
      reference = "manager-of-requester"
    }
  }

  # Step 3: Any of these groups can provide final approval
  approval_step {
    quantifier = "any"
    skip_after = "1h0m0s"
    approvers {
      group_id = sdm_group.security_team.id
    }
    approvers {
      group_id = sdm_group.administrators.id
    }
    approvers {
      reference = "manager-of-manager-of-requester"
    }
  }
}

####################################
# Create Mixed Approval Workflow (Groups + Individuals)
####################################
resource "sdm_approval_workflow" "mixed_approval_workflow" {
  name          = "Mixed Approval Workflow"
  description   = "A workflow combining group approvers with individual approvers"
  approval_mode = "manual"

  approval_step {
    quantifier = "any"
    skip_after = "4h0m0s"
    # Group approver
    approvers {
      group_id = sdm_group.security_team.id
    }
    # Individual approver
    approvers {
      account_id = sdm_account.security_lead.id
    }
    # Manager reference
    approvers {
      reference = "manager-of-requester"
    }
  }
}

####################################
# Create Department-Based Approval Workflow
####################################
resource "sdm_approval_workflow" "department_approval_workflow" {
  name          = "Department-Based Approval Workflow" 
  description   = "Different approval requirements based on department groups"
  approval_mode = "manual"

  # First, any department lead can review
  approval_step {
    quantifier = "any"
    skip_after = "8h0m0s"
    approvers {
      group_id = sdm_group.security_team.id
    }
    approvers {
      group_id = sdm_group.devops_team.id
    }
  }

  # Then, administrators must approve
  approval_step {
    quantifier = "all"
    skip_after = "24h0m0s"
    approvers {
      group_id = sdm_group.administrators.id
    }
  }
}

####################################
# Output Information
####################################
output "approval_workflow_ids" {
  value = {
    group_based_workflow = sdm_approval_workflow.group_based_approval_workflow.id
    mixed_workflow = sdm_approval_workflow.mixed_approval_workflow.id
    department_workflow = sdm_approval_workflow.department_approval_workflow.id
  }
  description = "IDs of the created approval workflows"
}

output "approver_groups" {
  value = {
    security_team_id = sdm_group.security_team.id
    administrators_id = sdm_group.administrators.id
    devops_team_id = sdm_group.devops_team.id
  }
  description = "Group IDs used as approvers in workflows"
}

output "workflow_summary" {
  value = {
    "Group-Based Workflow" = "3-step approval with group-based approvers"
    "Mixed Workflow" = "1-step approval combining groups, individuals, and references"  
    "Department Workflow" = "2-step departmental approval process"
  }
  description = "Summary of approval workflows demonstrating group approvers"
}