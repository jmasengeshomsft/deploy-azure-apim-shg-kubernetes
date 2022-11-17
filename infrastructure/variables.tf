
variable "apim_gateway_name" {
  description = "The name of the API Management Gateway"
  type        = string
}

variable "apim_rg" {
  description = "The API Management Resource Group"
  type        = string
}


variable "apim_name" {
  description = "The API Management ID"
  type        = string
}

variable "apim_gateway_description" {
  description = "The description of the API Management Gateway"
  type        = string
  default     = "API Management Gateway"
}

variable "apim_gateway_region" {
  description = "The region of the API Management Gateway"
  type        = string
}

# variable "kv_name" {
#   description = "The name of the Key Vault"
#   type        = string
# }

# variable "kv_rg" {
#   description = "The name of the Key Vault rg"
#   type        = string
# }