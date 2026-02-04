# StrongDM Discovery - GCP Terraform Configuration

This Terraform configuration fully automates the setup of StrongDM Discovery for GCP, including
creating the discovery connector and configuring Workload Identity Federation for OIDC authentication.

This configuration is compatible with both [Terraform](https://www.terraform.io/) and [OpenTofu](https://opentofu.org/).

## Overview

This configuration creates:

1. **StrongDM Discovery Connector** - A connector configured to discover resources in your GCP projects
2. **Workload Identity Pool** - A container for external identities that can access GCP resources
3. **OIDC Provider** - Configured to trust StrongDM's OIDC issuer for token validation
4. **IAM Role Bindings** - Grants the `roles/viewer` role to the StrongDM principal across your target projects

## Files Included

| File | Description |
|------|-------------|
| `main.tf` | Complete configuration with all resources |
| `variables.tf` | Input variable definitions |
| `outputs.tf` | Output definitions (connector ID, pool ID, etc.) |

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0 or [OpenTofu](https://opentofu.org/docs/intro/install/) >= 1.5.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (gcloud CLI)
- StrongDM API credentials (API access key and secret)
- A GCP project to host the Workload Identity Pool
- GCP projects you want StrongDM to discover resources in

## Required Input Variables

| Variable | Description |
|----------|-------------|
| `project_ids` | List of GCP project IDs to scan for discoverable resources |

## Optional Input Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `services` | `["GKE", "SQL", "GCE"]` | GCP services to scan |
| `connector_name` | `gcp-discovery-connector` | Name for the connector |
| `pool_id` | `strongdm-discovery-pool` | Workload Identity Pool ID |
| `provider_id` | `strongdm-discovery-provider` | OIDC Provider ID |
| `scan_period` | `Daily` | Scan frequency (TwiceDaily or Daily) |

## Required Permissions

### StrongDM API Permissions

The StrongDM API key needs permissions to create connectors and to view organization settings

### GCP Permissions

#### On the Project Hosting Workload Identity Pool

- `iam.workloadIdentityPools.create`
- `iam.workloadIdentityPools.get`
- `iam.workloadIdentityPoolProviders.create`
- `iam.workloadIdentityPoolProviders.get`

These are included in:
- `roles/iam.workloadIdentityPoolAdmin`
- `roles/owner`

#### On Each Target Project

- `resourcemanager.projects.getIamPolicy`
- `resourcemanager.projects.setIamPolicy`

These are included in:
- `roles/resourcemanager.projectIamAdmin`
- `roles/owner`

## Usage

### 1. Set Up Authentication

#### StrongDM API

Set your StrongDM API credentials:

```bash
export SDM_API_ACCESS_KEY="your-api-access-key"
export SDM_API_SECRET_KEY="your-api-secret-key"
```

#### GCP

Authenticate with GCP:

```bash
gcloud auth application-default login
```

Set your default project (this is where the Workload Identity Pool will be created):

```bash
gcloud config set project your-project-id
export GOOGLE_PROJECT="your-project-id"
```

Or if using a service account:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

### 2. Create terraform.tfvars

```hcl
project_ids           = ["project-1", "project-2"]

# Optional overrides
services       = ["GKE", "SQL", "GCE"]
connector_name = "my-gcp-discovery"
pool_id        = "strongdm-pool"
provider_id    = "strongdm-provider"
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

### Check GCP Resources

```bash
# Check the Workload Identity Pool
gcloud iam workload-identity-pools describe strongdm-discovery-pool \
  --project=your-project-id \
  --location=global

# Check the OIDC Provider
gcloud iam workload-identity-pools providers describe strongdm-discovery-provider \
  --workload-identity-pool=strongdm-discovery-pool \
  --project=your-project-id \
  --location=global

# Check IAM bindings on a target project
gcloud projects get-iam-policy <target-project-id> \
  --flatten="bindings[].members" \
  --filter="bindings.role:roles/viewer AND bindings.members:principal://"
```

## How It Works

1. Terraform creates a StrongDM discovery connector configured with your GCP project IDs

2. A Workload Identity Pool and OIDC Provider are created in the current project

3. IAM bindings grant the `roles/viewer` role to the connector's principal on each target project

4. StrongDM generates signed JWT tokens that are exchanged with GCP's Security Token Service

5. GCP validates the token and issues a federated access token

6. The connector uses the Viewer role to discover resources across your projects

## Cleanup

To remove all resources:

```bash
terraform destroy
```

## Troubleshooting

### "Permission denied" errors during apply

Ensure you have the required IAM permissions on both the workload identity project and all target projects.

### "Workload Identity Pool already exists"

Import the existing pool:

```bash
terraform import google_iam_workload_identity_pool.sdm \
  projects/your-project-id/locations/global/workloadIdentityPools/strongdm-discovery-pool
```

### Discovery not finding resources

1. Verify the IAM bindings were created on the target projects
2. Check that the connector ID in StrongDM matches the subject in the OIDC provider
3. Ensure the OIDC issuer URL is correct

## Security Considerations

- The `roles/viewer` role grants read-only access; resources cannot be modified
- Each connector has a unique subject claim preventing cross-connector access
- Token validation ensures only StrongDM-issued tokens are accepted
- Workload Identity Federation provides secure, keyless authentication
