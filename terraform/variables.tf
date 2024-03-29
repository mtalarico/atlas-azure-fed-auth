variable "vault" {
  type = object({
    api_key_path = string
  })
}

variable "atlas" {
  type = object({
    region = string
    org_id = string
    idp_id = string
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
