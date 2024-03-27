variable "mongodb_atlas" {
  type = object({
    region      = string
    public_key  = string
    private_key = string
    idp_id      = string
  })
}

variable "azure" {
  type = object({
    region                  = string
    human_user_upn          = string
    human_user_display_name = string
    human_user_password     = string
    prefix                  = string
    aks_ns                  = string
  })
}
