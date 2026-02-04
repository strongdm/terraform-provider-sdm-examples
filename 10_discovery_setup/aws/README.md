# StrongDM Discovery - AWS Terraform Configuration

This Terraform configuration fully automates the setup of StrongDM Discovery for AWS, including
creating the discovery connector and configuring AWS IAM for OIDC authentication.

This configuration is compatible with both [Terraform](https://www.terraform.io/) and [OpenTofu](https://opentofu.org/).

## Overview

This configuration creates:

1. **StrongDM Discovery Connector** - A connector configured to discover resources in your AWS accounts
2. **IAM OIDC Provider** - Configured to trust StrongDM's OIDC issuer for token validation
3. **IAM Role** - A role that can be assumed via web identity with ReadOnlyAccess policy

## Files Included

| File | Description |
|------|-------------|
| `main.tf` | Root configuration with sdm_connector and module invocation |
| `variables.tf` | Input variable definitions |
| `outputs.tf` | Output definitions (connector ID, role ARN, etc.) |
| `modules/aws/main.tf` | IAM OIDC provider and role resource definitions |
| `modules/aws/vars.tf` | Module input variable definitions |
| `modules/aws/outputs.tf` | Module output definitions |

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.3.0 or [OpenTofu](https://opentofu.org/docs/intro/install/) >= 1.3.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- StrongDM API credentials (API access key and secret)
- Access to each AWS account you want to scan

## Required Input Variables

| Variable | Description |
|----------|-------------|
| `account_ids` | List of AWS account IDs to scan for discoverable resources |
| `region` | Region for your AWS credentials |

## Optional Input Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `services` | `["RDS", "EC2", "EKS"]` | AWS services to scan |
| `connector_name` | `aws-discovery-connector` | Name for the connector |
| `role_name` | `StrongDMDiscoveryReadOnly` | IAM role name |
| `scan_period` | `Daily` | Scan frequency (TwiceDaily or Daily) |

## Required Permissions

### StrongDM API Permissions

The StrongDM API key needs permissions to create connectors and to view organization settings 

### AWS IAM Permissions

The user or role running Terraform needs these permissions **in each target AWS account**:

- `iam:CreateOpenIDConnectProvider`
- `iam:GetOpenIDConnectProvider`
- `iam:DeleteOpenIDConnectProvider`
- `iam:CreateRole`
- `iam:GetRole`
- `iam:DeleteRole`
- `iam:AttachRolePolicy`
- `iam:DetachRolePolicy`
- `iam:GetRolePolicy`

These permissions are included in:
- `IAMFullAccess`
- `AdministratorAccess`

## Usage

### 1. Set Up Authentication

#### StrongDM API

Set your StrongDM API credentials:

```bash
export SDM_API_ACCESS_KEY="your-api-access-key"
export SDM_API_SECRET_KEY="your-api-secret-key"
```

#### AWS

Configure AWS authentication. Options include:

```bash
# Option 1: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"

# Option 2: AWS CLI profile
aws configure --profile myprofile
```

### 2. Create terraform.tfvars

```hcl
account_ids           = ["123456789012", "234567890123"]

# Optional overrides
services       = ["RDS", "EC2", "EKS", "Redshift"]
connector_name = "my-aws-discovery"
```

### 3. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

### Multi-Account Setup

For scanning multiple AWS accounts, you need to configure provider aliases for each account.
Edit `main.tf` to add provider configurations:

```hcl
provider "aws" {
  alias = "account_2"
  assume_role {
    role_arn = "arn:aws:iam::234567890123:role/TerraformExecutionRole"
  }
}

module "sdm_discovery_aws_account_2" {
  source = "./modules/aws"
  providers = {
    aws = aws.account_2
  }
  issuer_url    = local.issuer_url
  connector_ids = toset([sdm_connector.aws_discovery.id])
  role_name     = var.role_name
}
```

## Verification

After applying, verify the setup:

### Check the Connector in StrongDM

The connector ID will be displayed in the Terraform output.

### Check AWS IAM Resources

```bash
# List OIDC providers
aws iam list-open-id-connect-providers

# Check the IAM role
aws iam get-role --role-name StrongDMDiscoveryReadOnly

# Check the trust policy
aws iam get-role --role-name StrongDMDiscoveryReadOnly --query 'Role.AssumeRolePolicyDocument'
```

## How It Works

1. Terraform creates a StrongDM discovery connector configured with your AWS account IDs

2. For each account, Terraform creates:
   - An IAM OIDC provider trusting StrongDM's issuer
   - An IAM role with a trust policy allowing the connector to assume it

3. StrongDM generates signed JWT tokens and uses `sts:AssumeRoleWithWebIdentity` to get temporary credentials

4. The connector uses the ReadOnlyAccess policy to discover resources

## Cleanup

To remove all resources:

```bash
terraform destroy
```

## Troubleshooting

### "Access Denied" errors during apply

Ensure you have the required IAM permissions in each target account.

### "OpenIDConnectProvider already exists"

Import the existing provider:

```bash
terraform import 'module.sdm_discovery_aws.aws_iam_openid_connect_provider.discovery' \
  arn:aws:iam::ACCOUNT_ID:oidc-provider/app.strongdm.com/oidc/your-subdomain
```

### Discovery not finding resources

1. Verify the IAM role has the correct trust policy
2. Check the connector ID matches in StrongDM and AWS
3. Ensure the ReadOnlyAccess policy is attached to the role

## Security Considerations

- The `ReadOnlyAccess` policy grants read-only access; resources cannot be modified
- Each connector has a unique subject claim preventing cross-connector access
- Token validation ensures only StrongDM-issued tokens are accepted

