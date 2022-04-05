# Bicep Module Registry with GitHub OIDC authentication

A secretless implementation of a Bicep module registry using [GitHub Open ID Connect](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure) and [Azure AD workload identity federation](https://docs.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation-create-trust-github?tabs=azure-portal).

The solution deploys Azure Container Registry and configures Azure Role Based Access Control to allow the GitHub Repository to push bicep modules to it through OIDC.

## Requirements

- jq
- [GitHub CLI](https://cli.github.com/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Roadmap

- [ ] Support for GitHub Releases, waiting on [Federated identity credentials support for wildcards #373](https://github.com/Azure/azure-workload-identity/issues/373)

