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

provider "mongodbatlas" {
  public_key  = var.mongodb_atlas.public_key
  private_key = var.mongodb_atlas.private_key
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
