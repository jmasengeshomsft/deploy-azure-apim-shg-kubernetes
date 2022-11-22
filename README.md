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

The workflows to create and delete the resources are provided under .github/worklows: **apim-sgh-infra-deploy.yaml** and **apim-sgh-infra-deploy.yaml**. These workflows were created following [Hashcorp's reference Action](https://github.com/hashicorp/setup-terraform) reference.

- Set up the following secrets for Azure ARM authentication

      jobs:
        terraform:
          name: 'Terraform'
          env:
            ARM_CLIENT_ID: ${{ secrets.AZ_TERRAFORM_CLIENT_ID }}
            ARM_CLIENT_SECRET: ${{ secrets.AZ_TERRAFORM_SECRET }}
            ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUB_ID }}
            ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
            
 - Create an Azure Storage and container for Terraform state storage. Make sure this section in the **provider.tf** is uncommented: 
 
             terraform {
              backend "azurerm" {
                resource_group_name  = "sre-rg"
                storage_account_name = "jmtfstatestr"
                container_name       = "apim-sh-gateway"
                key                  = "apim-sh-gateway.tfstate"
              }
            }
  - Adjust the runner for the pipeline. Defaults to a linux runner
  - For development, this pipeline must be triggered. Adjust the trigger for production

## Deploying the Self-Hosted Gateway

While the Self-Hosted Gateway can be deployed on any host that can run docker containers, this project shows how to deploy it on a Kubernetes cluster. Our demo uses AKS but most of users run APIM's gateways on other distributions outside of Azure. Unless you want to provide a local gateway inside a cluster from the latency perspective, if your workload is in Azure, the managed gateway will work better. 

The goal here is to have a running SHG pod on a cluster which is able to prublish its heartbeat to APIM's control plane. If you want to deploy a gateway manually, follow this tutorial: https://learn.microsoft.com/en-us/azure/api-management/how-to-deploy-self-hosted-gateway-azure-kubernetes-service

Navigate to your gateway inside an APIM instance and click on Deployment. You can deploy an APIM on Kubernetes in three ways:

- [Native YAML (with or without Kustomize)](https://learn.microsoft.com/en-us/azure/api-management/how-to-deploy-self-hosted-gateway-kubernetes)
- [Helm Chart](https://learn.microsoft.com/en-us/azure/api-management/how-to-deploy-self-hosted-gateway-kubernetes-helm) 
- [Azure Arc Extension](https://learn.microsoft.com/en-us/azure/api-management/how-to-deploy-self-hosted-gateway-azure-arc)

Practically, the helm deployment is better and easier, but for simplicity, this repository uses YAML with Kustomize. The kustomization folder looks like the picture below. The deployment also needs a secret which contains the Gateway's auth token. It must be created securely either manually or through other tools.

![image](https://user-images.githubusercontent.com/86074746/203437862-01c78c48-2be3-4bc6-82d1-71ff730b7dfd.png)

The ConfigMap contains the Configuration URL and other settings. To be explored later.

### How do deploy with Github Actions

- Get the Token from the Gateway's panel in Azure. Deploy the secret in cluster namespace like this: 

      kubectl create secret generic jm-gateway -n <gateway namespace> --from-literal=value="<token>"  --type=Opaque
      
- Get the Configuration Url and add it in the configmap yaml file like below:


      data:
        config.service.endpoint: "apim-jmapim-dev-canadacentral-001.configuration.azure-api.net"
        neighborhood.host: "azure-api-management-shg-instance-discovery"
        runtime.deployment.artifact.source: "Azure Portal"
        runtime.deployment.mechanism: "YAML"
        runtime.deployment.orchestrator.type: "Kubernetes"

- In the workflow file **.github/apim-shg-helm-deploy.yaml**, update secrets for Azure Authentication

           - name: Azure login
              uses: azure/login@v1.4.6
              with:
                creds: '${{ secrets.AZURE_CREDENTIALS }}'

 - Our deployment is targeting a private AKS cluster, read about [Azure/K8s-Deploy](https://github.com/Azure/k8s-deploy) ction for other parameters. If you are targeting a public cluster, remove the flowing arguments on the Azure/K8s-Deploy action: **resource-group, name, and private-cluster**
 
       - name: Deploys application
        uses: Azure/k8s-deploy@v4
        with:
          action: deploy
          resource-group: jm-dev-aks-rg
          name: jm-dev-cluster
          namespace: 'conference-gw'
          private-cluster: true
          # manifests: ${{ env.DEPLOYMENT_MANIFEST_PATH }}
          manifests: ${{ steps.bakeKustomize.outputs.manifestsBundl
 
 At this point, you should be able to run the pipeline successfully. Minor modifications can be made for other Kubernetes distributions.
 
 ## End To End CI/CD Process for APIM with a SHG
 
 An sample .net Core application was included under Sample-APIs. A pipeline to build, package, deploy to AKS, and publishing APIs to APIM was provided under **.github/workflows/apim-shg-helm-sample-api.yaml**
