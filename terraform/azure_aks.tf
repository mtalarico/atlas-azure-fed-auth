resource "azurerm_resource_group" "example_aks_rg" {
  name     = "${var.azure.prefix}-example-aks-rg"
  location = var.azure.region
}

resource "azurerm_kubernetes_cluster" "example_aks_cluster" {
  name                      = "${var.azure.prefix}-example-aks-cluster"
  location                  = azurerm_resource_group.example_aks_rg.location
  resource_group_name       = azurerm_resource_group.example_aks_rg.name
  dns_prefix                = "${var.azure.prefix}exampleaks"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2pds_v5"
    temporary_name_for_rotation = "foo"
  }

  identity {
    type = "SystemAssigned"
  }
}
