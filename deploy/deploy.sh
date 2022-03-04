GH_ORG='rjfmachado'
GH_REPO='bicepregistry'
GH_ENTITY_TYPE='Branch'
GH_ENTITY_NAME='main'
RG_NAME='ricardmabicep'
LOCATION='westeurope'
AAD_APP_NAME='ricardmabicepregistrypush'

#Create the AAD app to setup federated identity with GH
az ad app create --display-name $AAD_APP_NAME -o none
AAD_APP_OID=$(az ad app list --display-name $AAD_APP_NAME -o tsv --query [].objectId)
AAD_APP_APPID=$(az ad app list --display-name $AAD_APP_NAME -o tsv --query [].appId)
AAD_TENANT_ID=$(az account show -o tsv --query tenantId)
AZURE_SUBSCRIPTION_ID=$(az account show -o tsv --query id)


az rest --method POST --uri "https://graph.microsoft.com/beta/applications/$AAD_APP_OID/federatedIdentityCredentials" --body "{\"name\":\"GitHub\",\"issuer\":\"https://token.actions.githubusercontent.com/\",\"subject\":\"repo:$GH_ORG/$GH_REPO:ref:refs/heads/$GH_ENTITY_NAME\",\"description\":\"GitHub\",\"audiences\":[\"api://AzureADTokenExchange\"]}" -o none

#
#repo:{Organization}/{Repository}:ref:refs/heads/{Branch}
#repo:{Organization}/{Repository}:pull_request
#repo:{Organization}/{Repository}:ref:refs/tags/{Tag}


#setup a Service Principal in the app, it's required for Azure RBAC. Note there's no secret
az ad sp create --id $AAD_APP_APPID -o none
AAD_APP_SPID=$(az ad sp list --display-name $AAD_APP_NAME -o tsv --query [].objectId)

gh secret set AZURE_CLIENT_ID --body "$AAD_APP_SPID" --repo $GH_ORG/$GH_REPO
gh secret set AZURE_SUBSCRIPTION_ID --body "$AZURE_SUBSCRIPTION_ID" --repo $GH_ORG/$GH_REPO
gh secret set AZURE_TENANT_ID --body "$AAD_TENANT_ID" --repo $GH_ORG/$GH_REPO

#Setup the ACR and allow acrpush RBAC access from the GH repo
az deployment sub create --template-file ~/dev/github.com/rjfmachado/bicepregistry/infra/bicepacr.bicep --location westeurope -o table --parameters name=$RG_NAME location=$LOCATION principalId=$AAD_APP_SPID roleDefinitionIdOrName=acrPush --query outputs
az role assignment create --assignee $AAD_APP_SPID --role "Contributor" -o none