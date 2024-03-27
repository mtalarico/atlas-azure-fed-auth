resource "azurerm_user_assigned_identity" "example_ase_mi" {
  location            = var.azure.region
  name                = "${var.azure.prefix}-example-ase-mi"
  resource_group_name = azurerm_resource_group.example_ase_rg.name
}

resource "azurerm_user_assigned_identity" "example_aks_mi" {
  location            = var.azure.region
  name                = "${var.azure.prefix}-example-aks-mi"
  resource_group_name = azurerm_resource_group.example_aks_rg.name
}

resource "azurerm_federated_identity_credential" "example_aks_fic" {
  name                = "${var.azure.prefix}-example-aks-fic"
  resource_group_name = azurerm_resource_group.example_aks_rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.example_aks_cluster.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.example_aks_mi.id
  subject             = "system:serviceaccount:${var.azure.aks_ns}:${var.azure.prefix}-example-aks-sa"
}


resource "azuread_group" "programmatic_group" {
  display_name     = "${var.azure.prefix}-programmatic"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

  members = [
    azurerm_user_assigned_identity.example_aks_mi.principal_id,
    azurerm_user_assigned_identity.example_ase_mi.principal_id
  ]
}

resource "azuread_group" "human_group" {
  display_name     = "${var.azure.prefix}-human"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

  members = [
    azuread_user.human_user.id
  ]
}

resource "azuread_user" "human_user" {
  user_principal_name = var.azure.human_user_upn
  display_name        = var.azure.human_user_display_name
  password            = "mongodb!sAwesome"
}
