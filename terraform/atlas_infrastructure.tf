data "mongodbatlas_roles_org_id" "example_org" {
}

resource "mongodbatlas_project" "example_project" {
  name   = "example-project"
  org_id = data.mongodbatlas_roles_org_id.example_org.org_id
}


resource "mongodbatlas_cluster" "example_cluster" {
  project_id   = mongodbatlas_project.example_project.id
  name         = "example-cluster"
  cluster_type = "REPLICASET"
  replication_specs {
    num_shards = 1
    regions_config {
      region_name     = var.atlas.region
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
  }
  cloud_backup                 = true
  auto_scaling_disk_gb_enabled = true
  provider_name                = "AZURE"
  provider_instance_size_name  = "M10"
}

resource "mongodbatlas_database_user" "example_human_user" {
  username           = "${var.atlas.idp_id}/${azuread_group.human_group.object_id}"
  project_id         = mongodbatlas_project.example_project.id
  auth_database_name = "admin"
  oidc_auth_type     = "IDP_GROUP"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }
}

resource "mongodbatlas_database_user" "example_programmatic_user" {
  username           = "${var.atlas.idp_id}/${azuread_group.programmatic_group.object_id}"
  project_id         = mongodbatlas_project.example_project.id
  auth_database_name = "admin"
  oidc_auth_type     = "IDP_GROUP"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
}

# programmatic private endpoint

# resource "mongodbatlas_privatelink_endpoint" "example_programmatic_pl" {
#   project_id    = mongodbatlas_project.example_project.id
#   provider_name = "AZURE"
#   region        = "US_EAST"
# }

# resource "azurerm_private_endpoint" "example_programmatic_pl_endpoint" {
#   name                = "endpoint-test"
#   location            = azurerm_resource_group.example_ase_rg.location
#   resource_group_name = azurerm_resource_group.example_ase_rg.name
#   subnet_id           = azurerm_subnet.example_ase_subnet.id
#   private_service_connection {
#     name                           = mongodbatlas_privatelink_endpoint.example_programmatic_pl.private_link_service_name
#     private_connection_resource_id = mongodbatlas_privatelink_endpoint.example_programmatic_pl.private_link_service_resource_id
#     is_manual_connection           = false
#     subresource_names              = ["hostingEnvironments"]
#   }

# }

# resource "mongodbatlas_privatelink_endpoint_service" "example_programmatic_pl_service" {
#   project_id                  = mongodbatlas_privatelink_endpoint.example_programmatic_pl.project_id
#   private_link_id             = mongodbatlas_privatelink_endpoint.example_programmatic_pl.private_link_id
#   endpoint_service_id         = azurerm_private_endpoint.example_programmatic_pl_endpoint.id
#   private_endpoint_ip_address = azurerm_private_endpoint.example_programmatic_pl_endpoint.private_service_connection[0].private_ip_address
#   provider_name               = "AZURE"
# }
