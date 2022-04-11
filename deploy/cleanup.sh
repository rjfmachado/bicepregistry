RG_NAME='ricardmabicep'
AAD_APP_NAME='bicepregistrypush'

az group delete -n $RG_NAME --yes
AAD_APP_APPID=$(az ad app list --display-name $AAD_APP_NAME -o tsv --query [].appId)
AAD_APP_SPID=$(az ad sp list --display-name $AAD_APP_NAME -o tsv --query [].objectId)
az role assignment delete --assignee $AAD_APP_SPID
az ad app delete --id $AAD_APP_APPID