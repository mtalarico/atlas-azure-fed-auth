terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
    }
  }
}

provider "vault" {
  address = "http://127.0.0.1:8200"
}


data "vault_kv_secret" "atlas_creds" {
  path = var.vault.api_key_path
}

provider "mongodbatlas" {
  public_key  = data.vault_kv_secret.atlas_creds.data["public_key"]
  private_key = data.vault_kv_secret.atlas_creds.data["private_key"]
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
