resource "azuread_application_registration" "programmatic_app_reg" {
  display_name                   = "${var.azure.prefix}-atlas-programmatic"
  description                    = "Workflow OIDC Authentication"
  sign_in_audience               = "AzureADMyOrg"
  requested_access_token_version = 2
  group_membership_claims        = ["SecurityGroup"]
}

resource "azuread_application_identifier_uri" "programmatic_app_reg_uri" {
  application_id = azuread_application_registration.programmatic_app_reg.id
  identifier_uri = "api://${azuread_application_registration.programmatic_app_reg.client_id}"
}

resource "azuread_application_optional_claims" "programmatic_app_reg_claims" {
  application_id = azuread_application_registration.programmatic_app_reg.id

  access_token {
    name                  = "aud"
    additional_properties = ["use_guid"]
  }
}
