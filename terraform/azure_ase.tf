resource "azurerm_resource_group" "example_ase_rg" {
  name     = "${var.azure.prefix}-example-ase-rg"
  location = var.azure.region
}

resource "azurerm_virtual_network" "example_ase_vnet" {
  name                = "${var.azure.prefix}-example-ase-vnet"
  location            = azurerm_resource_group.example_ase_rg.location
  resource_group_name = azurerm_resource_group.example_ase_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example_ase_subnet" {
  name                 = "${var.azure.prefix}-example-ase-subnet"
  resource_group_name  = azurerm_resource_group.example_ase_rg.name
  virtual_network_name = azurerm_virtual_network.example_ase_vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "Microsoft.Web.hostingEnvironments"
    service_delegation {
      name    = "Microsoft.Web/hostingEnvironments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_app_service_environment_v3" "example_ase" {
  name                = "${var.azure.prefix}-example-ase"
  resource_group_name = azurerm_resource_group.example_ase_rg.name
  subnet_id           = azurerm_subnet.example_ase_subnet.id
}

resource "azurerm_service_plan" "example_ase_sp" {
  name                       = "${var.azure.prefix}-example-ase-sp"
  resource_group_name        = azurerm_resource_group.example_ase_rg.name
  location                   = azurerm_resource_group.example_ase_rg.location
  os_type                    = "Linux"
  sku_name                   = "I1v2"
  app_service_environment_id = azurerm_app_service_environment_v3.example_ase.id
}

resource "azurerm_linux_web_app" "example_ase_webapp" {
  name                = "${var.azure.prefix}-example-ase-python-app"
  resource_group_name = azurerm_resource_group.example_ase_rg.name
  location            = azurerm_service_plan.example_ase_sp.location
  service_plan_id     = azurerm_service_plan.example_ase_sp.id
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example_ase_mi.id]
  }
  site_config {
    application_stack {
      python_version = 3.12
    }
  }
  app_settings = {
    "MONGODB_URI" : mongodbatlas_cluster.example_cluster.srv_address,
    "AZURE_APP_CLIENT_ID" : azuread_application_registration.programmatic_app_reg.client_id
    "AZURE_IDENTITY_CLIENT_ID" : azurerm_user_assigned_identity.example_ase_mi.client_id
  }
}
