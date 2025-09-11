# Managing Groups with Terraform

This directory contains examples for managing groups and their relationships with accounts and roles using the StrongDM Terraform provider.

## Examples

### Basic Group Management
- [`groups_basic.tf`](./groups_basic.tf) - Create basic groups

### Account-Group Relationships  
- [`accounts_groups.tf`](./accounts_groups.tf) - Manage relationships between accounts (users) and groups

### Group-Role Relationships
- [`groups_roles.tf`](./groups_roles.tf) - Manage relationships between groups and roles

### Approval Workflows with Groups
- [`approval_workflows_with_groups.tf`](./approval_workflows_with_groups.tf) - Create approval workflows using groups as approvers

## Prerequisites

1. **Terraform Installation**: [Install Terraform](https://www.terraform.io/downloads.html)
2. **StrongDM API Keys**: Set the following environment variables:
   ```bash
   export TF_VAR_sdm_api_access_key="your-access-key"
   export TF_VAR_sdm_api_secret_key="your-secret-key"
   ```

## Usage

### Initialize Terraform
```bash
terraform init
```

### Plan and Apply Examples

#### Basic Groups
```bash
terraform plan -target=sdm_group.security_team -target=sdm_group.administrators -target=sdm_group.devops_team -target=sdm_group.qa_team
terraform apply -target=sdm_group.security_team -target=sdm_group.administrators -target=sdm_group.devops_team -target=sdm_group.qa_team
```

#### Account-Group Relationships
```bash
terraform plan accounts_groups.tf
terraform apply accounts_groups.tf
```

#### Group-Role Relationships  
```bash
terraform plan groups_roles.tf
terraform apply groups_roles.tf
```

#### Approval Workflows with Groups
```bash
terraform plan approval_workflows_with_groups.tf
terraform apply approval_workflows_with_groups.tf
```

### Apply All Examples
```bash
terraform plan
terraform apply
```

## Key Features Demonstrated

### Groups as Approvers
The approval workflow examples demonstrate how groups can be used as approvers in manual approval workflows:

```hcl
approval_step {
  quantifier = "any"
  skip_after = "2h0m0s"
  approvers {
    group_id = sdm_group.security_team.id
  }
}
```

### Mixed Approver Types
Workflows can combine different types of approvers:
- **Group approvers** (`group_id`)
- **Individual account approvers** (`account_id`)
- **Role approvers** (`role_id`)
- **Reference approvers** (`reference`)

### Flexible Group Membership
Users can be members of multiple groups, and groups can have multiple roles assigned to them, providing flexible permission management.

## Resource Types Used

- `sdm_group` - Creates groups
- `sdm_account_group` - Creates account-group relationships
- `sdm_group_role` - Creates group-role relationships  
- `sdm_approval_workflow` - Creates approval workflows with group approvers
- `sdm_account` - Creates user accounts
- `sdm_role` - Creates roles

## Clean Up

To remove all resources:
```bash
terraform destroy
```

## Further Reading

- [StrongDM Terraform Provider Documentation](https://registry.terraform.io/providers/strongdm/sdm/latest/docs)
- [Groups Feature Documentation](https://www.strongdm.com/docs)
- [Approval Workflows Documentation](https://www.strongdm.com/docs)