terraform {
  required_version = ">= 1.3.0"

  required_providers {
    sdm = {
      source  = "strongdm/sdm"
      version = "~> 15"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

locals {
  issuer_url = "https://app.strongdm.com/oidc/${var.sdm_website_subdomain}"
}

# Create Azure AD Application for StrongDM Discovery
resource "azuread_application" "strongdm_discovery" {
  display_name = var.application_name
}

# Create Service Principal for the application
resource "azuread_service_principal" "strongdm_discovery" {
  client_id = azuread_application.strongdm_discovery.client_id
}

# Create the StrongDM discovery connector for Azure
resource "sdm_connector" "azure_discovery" {
  azure {
    name             = var.connector_name
    description      = "Discovers resources across Azure subscriptions: ${join(", ", var.subscription_ids)}"
    scan_period      = var.scan_period
    subscription_ids = var.subscription_ids
    client_id        = azuread_application.strongdm_discovery.client_id
    services         = var.services
  }
}

# Configure Federated Identity Credential for StrongDM OIDC
# This allows StrongDM to authenticate using JWT tokens signed by its OIDC provider
resource "azuread_application_federated_identity_credential" "strongdm_discovery" {
  application_id = azuread_application.strongdm_discovery.id
  display_name   = "StrongDM Discovery Connector"
  description    = "Federated credential for StrongDM discovery scanner"

  issuer    = local.issuer_url
  subject   = "sdm:${var.sdm_website_subdomain}:${sdm_connector.azure_discovery.id}"
  audiences = ["api://AzureADTokenExchange"]
}

# Grant Reader role at subscription level for each subscription
resource "azurerm_role_assignment" "reader" {
  for_each = toset(var.subscription_ids)

  scope                = "/subscriptions/${each.value}"
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.strongdm_discovery.object_id
}
