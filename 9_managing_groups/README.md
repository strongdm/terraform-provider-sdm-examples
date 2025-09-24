# Managing Groups

This directory contains comprehensive CRUD examples for managing groups and their relationships with accounts and roles using the StrongDM Terraform provider.

## Examples

### Groups CRUD
[`groups_crud.tf`](./groups_crud.tf) - Complete CRUD operations for Groups
- **Create**: Create new groups with various configurations
- **Read**: List and query existing groups using data sources
- Demonstrates group creation and querying patterns
- Includes resource cleanup after demonstration

### AccountsGroups CRUD
[`accounts_groups_crud.tf`](./accounts_groups_crud.tf) - Complete CRUD operations for AccountsGroups
- **Create**: Link accounts (users) to groups
- **Read**: List and query account-group relationships using data sources
- Creates prerequisite accounts and groups
- Shows account-group relationship management patterns

### GroupsRoles CRUD
[`groups_roles_crud.tf`](./groups_roles_crud.tf) - Complete CRUD operations for GroupsRoles
- **Create**: Link groups to roles
- **Read**: List and query group-role relationships using data sources
- Creates prerequisite groups and roles
- Shows group-role relationship management patterns

## Prerequisites

1. **Terraform Installation**: [Install Terraform](https://www.terraform.io/downloads.html)
2. **StrongDM API Keys**: Set the following environment variables:
   ```bash
   export SDM_API_ACCESS_KEY="your-access-key"
   export SDM_API_SECRET_KEY="your-secret-key"
   ```

## Usage

Each example can be run independently and demonstrates the complete CRUD lifecycle:

```bash
# Groups CRUD example
cd groups_crud
terraform init
terraform plan
terraform apply

# AccountsGroups CRUD example
cd accounts_groups_crud
terraform init
terraform plan
terraform apply

# GroupsRoles CRUD example
cd groups_roles_crud
terraform init
terraform plan
terraform apply
```

## Features

- **Complete CRUD Operations**: Each example demonstrates Create, Read operations for groups and relationships
- **Comprehensive Resource Management**: Shows how to create accounts, groups, roles, and their relationships
- **Data Source Integration**: Examples demonstrate querying existing resources using Terraform data sources
- **Real-world Usage**: Examples show practical patterns for managing groups in production environments
- **Resource Dependencies**: Examples that require prerequisite resources create them automatically
- **Detailed Outputs**: All examples provide comprehensive output information for monitoring and validation

## Resource Types Used

- `sdm_group` - Creates groups
- `sdm_account` - Creates user accounts
- `sdm_account_group` - Creates account-group relationships
- `sdm_role` - Creates roles
- `sdm_group_role` - Creates group-role relationships

## Data Sources Used

- `data.sdm_group` - Queries existing groups
- `data.sdm_account_group` - Queries existing account-group relationships
- `data.sdm_group_role` - Queries existing group-role relationships

## Clean Up

To remove all resources:
```bash
terraform destroy
```

## Terraform Validation

To validate your Terraform configurations:

```bash
# Basic validation (run in each example directory)
terraform init
terraform validate
terraform fmt
terraform plan

# Example: Validate groups_crud
cd groups_crud
terraform init
terraform validate
terraform plan
```

## Further Reading

- [StrongDM Terraform Provider Documentation](https://registry.terraform.io/providers/strongdm/sdm/latest/docs)
- [Groups Feature Documentation](https://www.strongdm.com/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)