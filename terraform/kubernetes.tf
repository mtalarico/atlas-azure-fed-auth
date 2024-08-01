resource "kubernetes_service_account" "example_aks_sa" {
  metadata {
    name = "${var.azure.prefix}-example-aks-sa"
    annotations = {
      "azure.workload.identity/client-id" : azurerm_user_assigned_identity.example_aks_mi.client_id
    }
    namespace = var.azure.aks_ns
  }
}

resource "kubernetes_pod" "example_aks_pod" {
  metadata {
    name      = "${var.azure.prefix}-example-aks-app"
    namespace = "default"
    labels = {
      "azure.workload.identity/use" : "true"
    }
  }

  spec {
    service_account_name = "${var.azure.prefix}-example-aks-sa"
    container {
      image = "aypexe/workload-test:python" # USE FOR PYTHON
      # image = "aypexe/workload-test:java" # USE FOR JAVA
      name = "workload-test"

      env {
        name  = "MONGODB_URI"
        value = mongodbatlas_cluster.example_cluster.srv_address
      }

      env {
        name  = "AZURE_APP_CLIENT_ID"
        value = azuread_application_registration.programmatic_app_reg.client_id
      }

      env {
        name  = "AZURE_IDENTITY_CLIENT_ID"
        value = azurerm_user_assigned_identity.example_aks_mi.client_id
      }
    }
  }
}
