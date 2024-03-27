resource "azuread_application_registration" "human_app_reg" {
  display_name                   = "${var.azure.prefix}-atlas-human"
  description                    = "Workflow OIDC Authentication"
  sign_in_audience               = "AzureADMyOrg"
  requested_access_token_version = 2
  group_membership_claims        = ["SecurityGroup"]
}

# resource "azuread_application_identifier_uri" "human_app_reg_uri" {
#   application_id = azuread_application_registration.human_app_reg.id
#   identifier_uri = "api://${azuread_application_registration.example_app.client_id}"
# }

resource "azuread_application_redirect_uris" "human_app_reg_redirects" {
  application_id = azuread_application_registration.human_app_reg.id
  type           = "PublicClient"
  redirect_uris = [
    "http://localhost:27097/redirect"
  ]
}

resource "azuread_application_optional_claims" "human_app_reg_claims" {
  application_id = azuread_application_registration.human_app_reg.id

  access_token {
    name                  = "aud"
    additional_properties = ["use_guid"]
  }

  access_token {
    name = "email"
  }
}

resource "azuread_application_api_access" "human_app_reg_api" {
  application_id = azuread_application_registration.human_app_reg.id
  api_client_id  = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

  scope_ids = [
    data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["email"],
    data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["profile"],
    data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]
  ]
}
