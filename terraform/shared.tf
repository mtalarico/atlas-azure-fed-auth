data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "azuread_client_config" "current" {}
