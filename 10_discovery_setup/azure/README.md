# StrongDM Discovery - Azure Terraform Configuration

This Terraform configuration fully automates the setup of StrongDM Discovery for Azure, including
creating the Azure AD application, service principal, discovery connector, and configuring
federated identity for OIDC authentication.

This configuration is compatible with both [Terraform](https://www.terraform.io/) and [OpenTofu](https://opentofu.org/).

## Overview

This configuration creates:

1. **Azure AD Application** - An application registration for StrongDM discovery
2. **Service Principal** - The identity that will be granted access to your subscriptions
3. **StrongDM Discovery Connector** - A connector configured to discover resources in your Azure subscriptions
4. **Federated Identity Credential** - Enables OIDC authentication from StrongDM
5. **Role Assignments** - Grants Reader role on each subscription for resource discovery

## Files Included

| File | Description |
|------|-------------|
| `main.tf` | Complete configuration with all resources |
| `variables.tf` | Input variable definitions |
| `outputs.tf` | Output definitions (connector ID, client ID, etc.) |

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.3.0 or [OpenTofu](https://opentofu.org/docs/intro/install/) >= 1.3.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (az)
- StrongDM API credentials (API access key and secret)
- An Azure subscription

## Required Input Variables

| Variable | Description |
|----------|-------------|
| `sdm_website_subdomain` | Your StrongDM organization's Web Domain from https://app.strongdm.com/app/settings/account |
| `subscription_ids` | List of Azure subscription IDs to scan for discoverable resources |

## Optional Input Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `services` | `["AzureVM", "AzureSQL", "AKS"]` | Azure services to scan |
| `connector_name` | `azure-discovery-connector` | Name for the connector |
| `application_name` | `StrongDM Discovery` | Name for the Azure AD application |
| `scan_period` | `Daily` | Scan frequency (TwiceDaily or Daily) |

## Required Permissions

### StrongDM API Permissions

The StrongDM API key needs permissions to create connectors.

### Azure AD Permissions

- `Application.ReadWrite.All` - To create the application and federated identity credential

These permissions are included in:
- **Application Administrator**
- **Cloud Application Administrator**
- **Global Administrator**

### Azure Subscription Permissions

- `Microsoft.Authorization/roleAssignments/write` - To assign the Reader role

This permission is included in:
- **Owner**
- **User Access Administrator**

## Usage

### 1. Set Up Authentication

#### StrongDM API

Set your StrongDM API credentials:

```bash
export SDM_API_ACCESS_KEY="your-api-access-key"
export SDM_API_SECRET_KEY="your-api-secret-key"
```

#### Azure

Authenticate with Azure:

```bash
az login
```

If you have multiple subscriptions, set the default:

```bash
az account set --subscription "your-subscription-id"
```

### 2. Create terraform.tfvars

```hcl
sdm_website_subdomain = "your-org-subdomain"
subscription_ids      = ["00000000-0000-0000-0000-000000000000"]

# Optional overrides
services         = ["AzureVM", "AzureSQL", "AKS", "AzurePostgreSQL"]
connector_name   = "my-azure-discovery"
application_name = "StrongDM Discovery - Production"
```

### 3. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

## Verification

After applying, verify the setup:

### Check the Connector in StrongDM

The connector ID will be displayed in the Terraform output.

### Check Azure AD Resources

```bash
# Check the application (use the client_id from Terraform output)
az ad app show --id <client-id>

# Check the federated identity credential
az ad app federated-credential list --id <client-id>

# Check the service principal
az ad sp show --id <client-id>
```

### Check Role Assignments

```bash
az role assignment list --scope "/subscriptions/<subscription-id>" \
  --query "[?roleDefinitionName=='Reader']"
```

## How It Works

1. Terraform creates an Azure AD application and service principal

2. Terraform creates a StrongDM discovery connector configured with the application's client ID

3. A federated identity credential is created, allowing StrongDM to authenticate using OIDC tokens

4. Reader role is assigned to the service principal on each subscription

5. StrongDM generates signed JWT tokens that Azure AD validates against the federated credential

6. The connector uses the Reader role to discover resources across your subscriptions

## Cleanup

To remove all resources:

```bash
terraform destroy
```

## Troubleshooting

### "Insufficient privileges" errors during apply

Ensure you have the required Azure AD and subscription permissions listed above.

### "Federated credential already exists"

If a credential with the same subject already exists, you may need to import it or delete it first:

```bash
az ad app federated-credential delete --id <client-id> --federated-credential-id <credential-id>
```

### Discovery not finding resources

1. Verify the role assignment was created at the subscription level
2. Check that the federated identity credential has the correct issuer and subject
3. Ensure the OIDC issuer URL is correct

## Security Considerations

- The `Reader` role grants read-only access; resources cannot be modified
- Each connector has a unique subject claim preventing cross-connector access
- Token validation ensures only StrongDM-issued tokens are accepted
- The federated credential is scoped to a specific issuer and subject combination
