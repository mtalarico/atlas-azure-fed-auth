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
    vault = {
      source = "hashicorp/vault"
    }
  }
}


provider "vault" {
  address = var.vault.uri
}


data "vault_kv_secret" "atlas_creds" {
  count = var.vault.enabled ? 1 : 0
  path  = var.api_key.vault_path
}

locals {
  api_key = var.vault.enabled ? {
    public_key  = try(data.vault_kv_secret.atlas_creds[0].data["public_key"], "")
    private_key = try(data.vault_kv_secret.atlas_creds[0].data["private_key"], "")
    } : {
    public_key  = var.api_key.public_key
    private_key = var.api_key.private_key
  }
}

provider "mongodbatlas" {
  public_key  = local.api_key.public_key
  private_key = local.api_key.private_key
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
