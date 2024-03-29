# Bicep Module Registry with GitHub OIDC authentication

A secretless implementation of a Bicep module registry using [GitHub Open ID Connect](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure) and [Azure AD workload identity federation](https://docs.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation-create-trust-github?tabs=azure-portal).

The solution deploys Azure Container Registry and configures Azure Role Based Access Control to allow the GitHub Repository to push bicep modules to it through OIDC. However, the deployment workflow and approach can be reused to support many other Azure deployment scenarios.

## Deploy the solution

> Guidance/Scripts are Linux/bash.

1. Configure the GitHub cli to access your GitHub account.
2. Login to your target subscription with Azure CLI and ensure it's the current default subscription.
  ```bash
  az account show -o json --query name
  ```
3. Set the target Resource Group by configuring the environment variable AZURE_RG_NAME (default:bicepregistry)
4. Set the Azure Region by configuring the environment variable AZURE_LOCATION (default:westeurope)
5. Set the Azure AD Application names for both the deployment credential and the Module Push credential (defaults: bicepregistrydeploy and bicepregistryacrpush)
6. Set the Azure Container Registry name. This is required to be globally unique and defaults to a random name.
  ```bash
  export AZURE_RG_NAME='bicepregistry'
  export AZURE_LOCATION='westeurope'
  export AAD_DEPLOY_APP_NAME='bicepregistrydeploy'
  export AAD_ACRPUSH_APP_NAME='bicepregistryacrpush'
  export AZURE_ACR_NAME=$(echo $RANDOM | md5sum | head -c32)
  ```

6. Run the deployment pre-requisites script
  ```bash
  ./deploy/deploy.sh
  ```

7. Run the solution deployment workflow
  ```bash
  gh workflow run deploy.yml
  ```

8. Optionally, run the individual module deployment workflows
  ```
  gh workflow run
  ```

## Requirements

- jq
- [GitHub CLI](https://cli.github.com/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Roadmap

- [ ] Support for GitHub Releases, waiting on [Federated identity credentials support for wildcards #373](https://github.com/Azure/azure-workload-identity/issues/373)

