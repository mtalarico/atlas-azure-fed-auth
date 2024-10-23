data "mongodbatlas_federated_settings" "this" {
  org_id = data.mongodbatlas_roles_org_id.example_org.org_id
}

#resource "mongodbatlas_federated_settings_identity_provider" "workforce" {
#  federation_settings_id = data.mongodbatlas_federated_settings.this.id
#  associated_domains     = var.atlas.associated_domains
#  audience               = azuread_application_registration.human_app_reg.client_id
#  authorization_type     = "GROUP"
#  client_id              = azuread_application_registration.human_app_reg.client_id
#  description            = "Workforce Identity for human users via Azure Entra ID as an OIDC IdP"
#  issuer_uri             = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
#  idp_type               = "WORKFORCE"
#  name                   = "Azure Entra ID - Human"
#  protocol               = "OIDC"
#  requested_scopes       = ["openid", "${azuread_application_registration.human_app_reg.client_id}/.default"]
#  groups_claim           = "groups"
#  user_claim             = "upn"
#}

resource "mongodbatlas_federated_settings_identity_provider" "workload" {
  federation_settings_id = data.mongodbatlas_federated_settings.this.id
  associated_domains     = var.atlas.associated_domains
  audience               = azuread_application_registration.programmatic_app_reg.client_id
  authorization_type     = "GROUP"
  description            = "Workload Identity for programmatic access via Azure Entra ID as an Oauth IdP"
  issuer_uri             = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
  idp_type               = "WORKLOAD"
  name                   = "Azure Entra ID - Programmatic"
  protocol               = "OIDC"
  groups_claim           = "groups"
  user_claim             = "sub"
}

# --
# The below code imports the federation setting linked org object and patches it with a linked org that has the IdPs linked as data access IDPs.
#
# Since the lifetime of our resources are the lifetime of this module it is problematic to do automatically, as `terraform delete` would not
# work as expected. To just "unlink" the IDPs you would need to remove them from `data_access_identity_provider_ids` without deleting the entire
# `mongodbatlas_federated_settings_org_config` object.
#
# For this reason, its easier to just not worry about doing this via Terraform and mandate you manually link and unlink the IdPs to get everything
# working and before `terraform delete`
# --

# import {
#   to = mongodbatlas_federated_settings_org_config.org_connection
#   id = "${data.mongodbatlas_federated_settings.this.id}-${data.mongodbatlas_roles_org_id.example_org.org_id}"
# }

# resource "mongodbatlas_federated_settings_org_config" "org_connection" {
#   federation_settings_id     = data.mongodbatlas_federated_settings.this.id
#   org_id                     = data.mongodbatlas_roles_org_id.example_org.org_id
#   domain_restriction_enabled = false
#   data_access_identity_provider_ids = [
#     mongodbatlas_federated_settings_identity_provider.workload.idp_id,
#     mongodbatlas_federated_settings_identity_provider.workforce.idp_id
#   ]
# }
