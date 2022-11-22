# Deploying Azure APIM Self-Hosted Gateway on Kubernetes

This project is intended to provide a through implementation of Azure API Management's Self Hosted Gateway on Kubernetes. We will explore how to deploy a gateway on Kubernetes and then use it to provide local proxing using APIM's Policies. Use the the following links to learn more about APIM's Self-Hosted Gateway:

- [Self-hosted gateway overview](https://learn.microsoft.com/en-us/azure/api-management/self-hosted-gateway-overview)
- [Guidance for running self-hosted gateway on Kubernetes in production](https://learn.microsoft.com/en-us/azure/api-management/how-to-self-hosted-gateway-on-kubernetes-in-production)
- [Enterprise-Scale-APIM](https://learn.microsoft.com/en-us/azure/api-management/how-to-self-hosted-gateway-on-kubernetes-in-production)
- [Enterprise-Scale-APIM Lite](https://github.com/jmasengeshomsft/apim-landing-zone-accelerator-lite) (AKS as backend workload)


### This repository contains three projects:

-	**Infrastructure**: A terraform-based pipeline to deploy products, groups, gateways, and gateway API (including a github action workflow)
-	**Kubernetes**: A pipeline that deploys a gateway to an AKS Cluster. It takes a configuration URL and an auth token
-	**Sample-APIs**: An end-to-end CI/CD pipeline do build , package, deploy to AKS, and publish to APIM with a basic API codebase. The example uses a sample .NET CORE Web API found here: https://github.com/Azure-Samples/dotnet-core-api
