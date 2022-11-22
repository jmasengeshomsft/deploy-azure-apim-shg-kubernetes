# Deploying Azure APIM Self-Hosted Gateway on Kubernetes

This project is intended to provide a through implementation of Azure API Management's Self Hosted Gateway on Kubernetes. We will explore how to deploy a gateway on Kubernetes and then use it to provide local proxing using APIM's Policies. Use the the following links to learn more about APIM's Self-Hosted Gateway:

- [Self-hosted gateway overview](https://learn.microsoft.com/en-us/azure/api-management/self-hosted-gateway-overview)
- [Guidance for running self-hosted gateway on Kubernetes in production](https://learn.microsoft.com/en-us/azure/api-management/how-to-self-hosted-gateway-on-kubernetes-in-production)
- [Enterprise-Scale-APIM](https://github.com/Azure/apim-landing-zone-accelerator)
- [Enterprise-Scale-APIM Lite](https://github.com/jmasengeshomsft/apim-landing-zone-accelerator-lite) (AKS as backend workload)


### This repository contains three projects:

-	**Infrastructure**: A terraform-based pipeline to deploy products, groups, gateways, and gateway API (including a github action workflow)
-	**Kubernetes**: A pipeline that deploys a gateway to an AKS Cluster. It takes a configuration URL and an auth token
-	**Sample-APIs**: An end-to-end CI/CD pipeline do build , package, deploy to AKS, and publish to APIM with a basic API codebase. The example uses a sample .NET CORE Web API found here: https://github.com/Azure-Samples/dotnet-core-api


## Infrastructure Pipeline

This projects assumes you already have an instance of APIM with Developer or Premium SKU. If you do not have an instance, use any of these links to create an instance:
- [Create APIM Instance with Portal, CLI, Bicep. VS Code, PowerShell](https://learn.microsoft.com/en-us/azure/api-management/get-started-create-service-instance)
- [Enterprise-Scale-APIM](https://github.com/Azure/apim-landing-zone-accelerator)
- [Enterprise-Scale-APIM Lite](https://github.com/jmasengeshomsft/apim-landing-zone-accelerator-lite)

Using [Terraform APIM resources](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management), you can add more resources to this template. If no change, this project with deploy: a self-hosted gateway, a product, a group, two APIs under the product and gateway.

### Deploying locally

- Navigate to the infrastructure forlder and inspect resources to be deployed. You can add more if desired
- Make sure Terraform is installed locally.
- Comment out the section provider.tf that sets a remote storage (useful if deploying with GitHub Actions)

      terraform {
        backend "azurerm" {
          resource_group_name  = "sre-rg"
          storage_account_name = "jmtfstatestr"
          container_name       = "apim-sh-gateway"
          key                  = "apim-sh-gateway.tfstate"
        }
      }
 - update variables in variables.tfvars
 
          apim_rg                  = "rg-apim-me-dev-canadacentral-001"
          apim_name                = "apim-me-dev-canadacentral-001"
          apim_gateway_name        = "alibaba-cloud-china"
          apim_gateway_description = "jm-gateway2-canada-central1"
          apim_gateway_region      = "alicloud-kubernetes-cluster"
 
 - Run the following commands to initialize, plan, and apply your deployment
 
        #Initialize terraform 
        terraform init 
        
        #plan the deployment
        terraform plan
        
        #apply the deployment
        terraform apply
        
### Deploy with GitHub Actions
