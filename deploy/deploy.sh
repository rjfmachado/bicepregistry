# Get the current subscription id, tenant id, and Github organization and repository
GH_ORG=$(gh repo view --json nameWithOwner | jq .nameWithOwner | sed 's/\"//g' | cut -d'/' -f1)
GH_REPO=$(gh repo view --json nameWithOwner | jq .nameWithOwner | sed 's/\"//g' | cut -d'/' -f2)
GH_DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef | jq .defaultBranchRef.name | sed 's/\"//g')
AAD_TENANT_ID=$(az account show -o tsv --query tenantId)
AZURE_SUBSCRIPTION_ID=$(az account show -o tsv --query id)

# Create the Deploy AAD app and setup federated identity with GitHub
az ad app create --display-name $AAD_DEPLOY_APP_NAME -o none
AAD_DEPLOY_APP_OID=$(az ad app list --display-name $AAD_DEPLOY_APP_NAME -o tsv --query [].id)
AAD_DEPLOY_APP_APPID=$(az ad app list --display-name $AAD_DEPLOY_APP_NAME -o tsv --query [].appId)
az ad app federated-credential create --id $AAD_DEPLOY_APP_OID --parameters "{\"name\":\"mainbranch\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:$GH_ORG/$GH_REPO:ref:refs/heads/$GH_DEFAULT_BRANCH\",\"description\":\"GitHub\",\"audiences\":[\"api://AzureADTokenExchange\"]}" -o none

# Setup a Service Principal in the app, it's required for Azure RBAC. Note there's no secret added due to OIDC.
az ad sp create --id $AAD_DEPLOY_APP_APPID -o none
AAD_DEPLOY_APP_SPID=$(az ad sp list --display-name $AAD_DEPLOY_APP_NAME -o tsv --query [].id)

# Create the ACR Push AAD app and setup federated identity with GitHub
az ad app create --display-name $AAD_ACRPUSH_APP_NAME -o none
AAD_ACRPUSH_APP_OID=$(az ad app list --display-name $AAD_ACRPUSH_APP_NAME -o tsv --query [].id)
AAD_ACRPUSH_APP_APPID=$(az ad app list --display-name $AAD_ACRPUSH_APP_NAME -o tsv --query [].appId)
az ad app federated-credential create --id $AAD_ACRPUSH_APP_OID --parameters "{\"name\":\"mainbranch\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:$GH_ORG/$GH_REPO:ref:refs/heads/$GH_DEFAULT_BRANCH\",\"description\":\"GitHub\",\"audiences\":[\"api://AzureADTokenExchange\"]}" -o none

#setup a Service Principal in the app, it's required for Azure RBAC. Note there's no secret added due to OIDC.
az ad sp create --id $AAD_ACRPUSH_APP_APPID -o none
AAD_ACRPUSH_APP_SPID=$(az ad sp list --display-name $AAD_ACRPUSH_APP_NAME -o tsv --query [].id)

# Create the Target Resource Group
az group create --name $AZURE_RG_NAME --location $AZURE_LOCATION -o none

# Allow the Deploy app Owner access to the Resource Group
az role assignment create --assignee $AAD_DEPLOY_APP_SPID --role "Owner" --resource-group $AZURE_RG_NAME -o none

# Allow the ACR Push app read access to the ACR
# az role assignment create --assignee $AAD_ACRPUSH_APP_SPID --role "Reader" --resource-group $AZURE_RG_NAME -o none

# Update the Registry, TenantId, SubscriptionId and AppId's in GitHub
cat << EOF
Please run the following commands to update the necessary github actions secrets:

gh secret set AZURE_ACRPUSH_CLIENT_ID --body "$AAD_ACRPUSH_APP_APPID" --repo $GH_ORG/$GH_REPO
gh secret set AZURE_ACRPUSH_SP_ID --body "$AAD_ACRPUSH_APP_SPID" --repo $GH_ORG/$GH_REPO
gh secret set AZURE_DEPLOY_CLIENT_ID --body "$AAD_DEPLOY_APP_APPID" --repo $GH_ORG/$GH_REPO
gh secret set AZURE_SUBSCRIPTION_ID --body "$AZURE_SUBSCRIPTION_ID" --repo $GH_ORG/$GH_REPO
gh secret set AZURE_TENANT_ID --body "$AAD_TENANT_ID" --repo $GH_ORG/$GH_REPO
gh secret set AZURE_RG_NAME --body "$AZURE_RG_NAME" --repo $GH_ORG/$GH_REPO
gh secret set AZURE_ACR_NAME --body "$AZURE_ACR_NAME" --repo $GH_ORG/$GH_REPO
gh secret set AZURE_LOCATION --body "$AZURE_LOCATION" --repo $GH_ORG/$GH_REPO
EOF