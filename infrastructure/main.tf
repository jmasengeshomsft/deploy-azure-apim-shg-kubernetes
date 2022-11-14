

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
  product_id            = "ConfrenceAPI"
  api_management_name   = data.azurerm_api_management.apim_instance.name
  resource_group_name   = data.azurerm_api_management.apim_instance.resource_group_name
  display_name          = "Confrence API"
  description           = "Confrence API"
  subscription_required = true
  subscriptions_limit   = 2
  approval_required     = true
  published             = true
}

resource "azurerm_api_management_group" "conference_group" {
  name                = "ConferenceGroup"
  api_management_name = data.azurerm_api_management.apim_instance.name
  resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name
  display_name        = "Conference Group"
  description         = "This is the group for the conference API Users"
}

resource "azurerm_api_management_product_group" "conference_product_group" {
  product_id          = azurerm_api_management_product.Conference_product.product_id
  group_name          = azurerm_api_management_group.conference_group.name
  api_management_name = data.azurerm_api_management.apim_instance.name
  resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name
}

resource "azurerm_api_management_api" "conference_api" {
  name                = "conference-api"
  resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name
  api_management_name = data.azurerm_api_management.apim_instance.name
  revision            = "1"
  display_name        = "Conference API"
  path                = "conference-api"
  protocols           = ["https", "http"]

  import {
    content_format = "swagger-link-json"
    content_value  = "http://conferenceapi.azurewebsites.net/?format=json"
  }
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

#certifcate
data "azurerm_key_vault" "certs_kv" {
  name                = var.kv_name
  resource_group_name = var.apim_rg
}

data "azurerm_key_vault_certificate" "gw_cert" {
  name         = "conference-gw-jmasengeshoservices-com"
  key_vault_id = data.azurerm_key_vault.certs_kv.id
}






