# resource "vault_mount" "mongodbatlas" {
#   path        = "mongodbatlas"
#   type        = "mongodbatlas"
#   description = "MongoDB Atlas secret engine mount"
# }


# resource "vault_mongodbatlas_secret_role" "tf_key" {
#   mount           = vault_mount.mongodbatlas.path
#   name            = "test"
#   organization_id = var.atlas.org_id
#   roles           = ["ORG_OWNER"]
#   ttl             = "60"
#   max_ttl         = "120"
# }


data "vault_kv_secret" "atlas_creds" {
  path = "mongodbatlas/creds/test"
}
