
variable "apim_gateway_name" {
    description = "The name of the API Management Gateway"
    type        = string
}

variable "apim_id" {
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

# variable "spoke_vnet_subnets" {
#   type = list(object({
#     name      = string
#     range     = string                  
#   }))
#   default = [
#       {
#           name   = "default"
#           range  = "10.0.8.0/24"
#       }
#   ]
# }

