# Get the current subscription id, tenant id, and Github organization and repository
GH_ORG=$(gh repo view --json nameWithOwner | jq .nameWithOwner | sed 's/\"//g' | cut -d'/' -f1)
GH_REPO=$(gh repo view --json nameWithOwner | jq .nameWithOwner | sed 's/\"//g' | cut -d'/' -f2)
GH_DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef | jq .defaultBranchRef.name | sed 's/\"//g')
AAD_TENANT_ID=$(az account show -o tsv --query tenantId)
AZURE_SUBSCRIPTION_ID=$(az account show -o tsv --query id)

# Create the Deploy AAD app and setup federated identity with GitHub
az ad app create --display-name $AAD_DEPLOY_APP_NAME -o none
AAD_DEPLOY_APP_OID=$(az ad app list --display-name $AAD_DEPLOY_APP_NAME -o tsv --query [].objectId)
AAD_DEPLOY_APP_APPID=$(az ad app list --display-name $AAD_DEPLOY_APP_NAME -o tsv --query [].appId)
az rest --method POST --uri "https://graph.microsoft.com/beta/applications/$AAD_DEPLOY_APP_OID/federatedIdentityCredentials" --body "{\"name\":\"mainbranch\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:$GH_ORG/$GH_REPO:ref:refs/heads/$GH_DEFAULT_BRANCH\",\"description\":\"GitHub\",\"audiences\":[\"api://AzureADTokenExchange\"]}" -o none

# Setup a Service Principal in the app, it's required for Azure RBAC. Note there's no secret added due to OIDC.
az ad sp create --id $AAD_DEPLOY_APP_APPID -o none
AAD_DEPLOY_APP_SPID=$(az ad sp list --display-name $AAD_DEPLOY_APP_NAME -o tsv --query [].objectId)

# Create the ACR Push AAD app and setup federated identity with GitHub
az ad app create --display-name $AAD_ACRPUSH_APP_NAME -o none
AAD_ACRPUSH_APP_OID=$(az ad app list --display-name $AAD_ACRPUSH_APP_NAME -o tsv --query [].objectId)
AAD_ACRPUSH_APP_APPID=$(az ad app list --display-name $AAD_ACRPUSH_APP_NAME -o tsv --query [].appId)
az rest --method POST --uri "https://graph.microsoft.com/beta/applications/$AAD_ACRPUSH_APP_OID/federatedIdentityCredentials" --body "{\"name\":\"mainbranch\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:$GH_ORG/$GH_REPO:ref:refs/heads/$GH_DEFAULT_BRANCH\",\"description\":\"GitHub\",\"audiences\":[\"api://AzureADTokenExchange\"]}" -o none

#setup a Service Principal in the app, it's required for Azure RBAC. Note there's no secret added due to OIDC.
az ad sp create --id $AAD_ACRPUSH_APP_APPID -o none
AAD_ACRPUSH_APP_SPID=$(az ad sp list --display-name $AAD_ACRPUSH_APP_NAME -o tsv --query [].objectId)

# az




#Setup the ACR and allow acrpush RBAC access from the GH repo
# az deployment sub create --template-file ~/dev/github.com/rjfmachado/bicepregistry/infra/bicepacr.bicep --location westeurope -o table --parameters name=$RG_NAME location=$LOCATION principalId=$AAD_APP_SPID roleDefinitionIdOrName=acrPush --query outputs

#Update the Registry, TenantId, SubscriptionId and AppId in GitHub
gh secret set AZURE_CLIENT_ID --body "$AAD_ACRPUSH_APP_APPID" --repo $GH_ORG/$GH_REPO
gh secret set AZURE_SUBSCRIPTION_ID --body "$AZURE_SUBSCRIPTION_ID" --repo $GH_ORG/$GH_REPO
gh secret set AZURE_TENANT_ID --body "$AAD_TENANT_ID" --repo $GH_ORG/$GH_REPO
gh secret set REGISTRY --body "$(az deployment group show -g $RG_NAME -n $RG_NAME -o tsv --query properties.outputs.loginServer.value)" --repo $GH_ORG/$GH_REPO

