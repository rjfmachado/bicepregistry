RG_NAME='ricardmabicep'
AAD_APP_NAME='ricardmabicepregistrypush'

#Create the AAD app to setup federated identity with GH
az group delete -n $RG_NAME --yes
AAD_APP_APPID=$(az ad app list --display-name $AAD_APP_NAME -o tsv --query [].appId)
az ad app delete --id $AAD_APP_APPID