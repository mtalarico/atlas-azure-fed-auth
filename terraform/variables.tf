variable "vault" {
  description = "Vault configuration"
  type = object({
    enabled = bool
    uri     = string
  })
  default = {
    enabled = false
    uri     = ""
  }
}

variable "api_key" {
  description = "API Key details, either uses vault_path or manual entry depending on vault.enabled"
  type = object({
    vault_path  = string
    public_key  = string
    private_key = string
  })
  default = {
    vault_path  = ""
    public_key  = ""
    private_key = ""
  }
  sensitive = true
}

variable "atlas" {
  type = object({
    region             = string
    associated_domains = list(string)
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
