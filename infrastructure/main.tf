

data "azurerm_api_management" "apim_instance" {
  name                = var.apim_name
  resource_group_name = var.apim_rg
}

module "apim_gateway" {
  source            = "./modules/apim-gateway/"
  apim_id           = data.azurerm_api_management.apim_instance.id
  apim_gateway_name = var.apim_gateway_name
  # apim_gateway_description   = var.apim_gateway_description
  apim_gateway_region = var.apim_gateway_region
  # tags                       = var.tags
}

resource "azurerm_api_management_product" "Conference_product" {
  product_id            = "TodoAPI"
  api_management_name   = data.azurerm_api_management.apim_instance.name
  resource_group_name   = data.azurerm_api_management.apim_instance.resource_group_name
  display_name          = "Todo API"
  description           = "Todo API"
  subscription_required = true
  subscriptions_limit   = 2
  approval_required     = true
  published             = true
}

resource "azurerm_api_management_group" "conference_group" {
  name                = "TodoGroup"
  api_management_name = data.azurerm_api_management.apim_instance.name
  resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name
  display_name        = "Todo Group"
  description         = "This is the group for the Todo API Users"
}

resource "azurerm_api_management_product_group" "conference_product_group" {
  product_id          = azurerm_api_management_product.Conference_product.product_id
  group_name          = azurerm_api_management_group.conference_group.name
  api_management_name = data.azurerm_api_management.apim_instance.name
  resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name
}

resource "azurerm_api_management_api" "conference_api" {
  name                = "conference-app-api"
  resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name
  api_management_name = data.azurerm_api_management.apim_instance.name
  revision            = "1"
  display_name        = "Conference API"
  path                = "conference"
  protocols           = ["https", "http"]

  import {
    content_format = "swagger-link-json"
    content_value  = "http://conferenceapi.azurewebsites.net/?format=json"
  }
}

resource "azurerm_api_management_api" "todo_api" {
  name                = "todo-api"
  resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name
  api_management_name = data.azurerm_api_management.apim_instance.name
  revision            = "1"
  display_name        = "ToDo API"
  path                = "todo"
  protocols           = ["https", "http"]

  import {
    content_format = "openapi"
    content_value  = file("./apis/todo-api.json")
  }

  service_url      = "http://todo-api.conference-gw.svc.cluster.local"
}

resource "azurerm_api_management_product_api" "conferenceapi" {
  api_name            = azurerm_api_management_api.conference_api.name
  product_id          = azurerm_api_management_product.Conference_product.product_id
  api_management_name = data.azurerm_api_management.apim_instance.name
  resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name
}

resource "azurerm_api_management_gateway_api" "conference_api" {
  gateway_id = module.apim_gateway.gateway.id
  api_id     = azurerm_api_management_api.conference_api.id
}


resource "azurerm_api_management_product_api" "todoapi" {
  api_name            = azurerm_api_management_api.todo_api.name
  product_id          = azurerm_api_management_product.Conference_product.product_id
  api_management_name = data.azurerm_api_management.apim_instance.name
  resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name
}

resource "azurerm_api_management_gateway_api" "todo_api" {
  gateway_id = module.apim_gateway.gateway.id
  api_id     = azurerm_api_management_api.todo_api.id
}


#certifcate
# data "azurerm_key_vault" "certs_kv" {
#   name                = var.kv_name
#   resource_group_name = var.kv_rg
# }

# data "azurerm_key_vault_certificate" "gw_cert" {
#   name         = "conference-gw-jmasengeshoservices-com"
#   key_vault_id = data.azurerm_key_vault.certs_kv.id
# }

# resource "azurerm_api_management_certificate" "conference-api" {
#   name                = "conference-gw-jmasengeshoservices-com"
#   api_management_name = data.azurerm_api_management.apim_instance.name
#   resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name

#   key_vault_secret_id = data.azurerm_key_vault_certificate.gw_cert.secret_id
# }

# resource "azurerm_api_management_gateway_host_name_configuration" "conference_api_hostname" {
#   name              = "conference-gw-jmasengeshoservices-com"
#   api_management_id = data.azurerm_api_management.apim_instance.id
#   gateway_name      = module.apim_gateway.gateway.name

#   certificate_id                     = azurerm_api_management_certificate.conference-api.id
#   host_name                          = "conference-gw.jmasengeshoservices.com"
#   request_client_certificate_enabled = false
#   # http2_enabled                      = true
#   # tls10_enabled                      = true
#   # tls11_enabled                      = false
# }







