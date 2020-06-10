#!/bin/bash

set -e

SUBSCRIPTION=
TENANT=
LOCATION=UKSOUTH
RG_NAME=
RG_SECRET_NAME=
KV_NAME=
TF_STATE_STORAGE_ACCOUNT_NAME=
TF_STATE_CONTAINER_NAME=
SERVICEPRINCIPAL_NAME=
TAGS=


# Active subscription
az account set --subscription $SUBSCRIPTION

# Create the resource group if needed
echo "Creating $RG_NAME resource group if it does not exist..."
az group list --output tsv | grep $RG_NAME -q || az group create -l $LOCATION -n $RG_NAME --tags $TAGS

echo "Resource group $RG_NAME created."

echo "Creating $RG_SECRET_NAME resource group if it does not exist..."
az group list --output tsv | grep $RG_SECRET_NAME -q || az group create -l $LOCATION -n $RG_SECRET_NAME --tags $TAGS

echo "Resource group $RG_SECRET_NAME created."

# Create an Azure KeyVault
echo "Creating $KV_NAME key vault..."
az keyvault create -g $RG_SECRET_NAME -l $LOCATION --name $KV_NAME \
    --sku standard \
    --enable-soft-delete true \
    --tag $TAGS

echo "Key vault $KV_NAME created."

# Create the storage account
echo "Creating $TF_STATE_STORAGE_ACCOUNT_NAME storage account..."
az storage account create -g $RG_SECRET_NAME -l $LOCATION \
    --name $TF_STATE_STORAGE_ACCOUNT_NAME \
    --kind StorageV2 \
    --sku Standard_LRS \
    --encryption-services blob \
    --https-only true \
    --tags $TAGS

echo "Storage account $TF_STATE_STORAGE_ACCOUNT_NAME created."

# Retrieve the storage account key
echo "Retrieving storage account key..."
ACCOUNT_KEY=$(az storage account keys list --resource-group $RG_SECRET_NAME --account-name $TF_STATE_STORAGE_ACCOUNT_NAME --query '[0]'.value -o tsv)

echo "Storage account key retrieved."

# Create a storage container (for the Terraform State)
echo "Creating $TF_STATE_CONTAINER_NAME storage container..."
az storage container create --name $TF_STATE_CONTAINER_NAME \
    --account-name $TF_STATE_STORAGE_ACCOUNT_NAME \
    --account-key $ACCOUNT_KEY \
    --public-access off

# Store the Terraform State Storage Key into KeyVault
echo "Store storage access key into key vault secret..."
az keyvault secret set --name angdevst-key --value $ACCOUNT_KEY --vault-name $KV_NAME

echo "Key vault secret created."

# Generate random string for Service Principal
SP_SECRET=$(openssl rand -base64 64)

# Create Service Principal with permissions to RG
echo "Creating $SERVICEPRINCIPAL_NAME Service Principal..."
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION/resourceGroups/$RG_NAME" --name $SERVICEPRINCIPAL_NAME

echo "Service Principal created"

echo "Reset credential..."
az ad sp credential reset --name $SERVICEPRINCIPAL_NAME --password "$SP_SECRET"

echo "Credentials reset and storing in Key Vault..."
az keyvault secret set --name "ARM-CLIENT-SECRET" --value "$SP_SECRET" --vault-name $KV_NAME

# Give SP access to KV Secrets
SP_OBJ_ID=$(az ad sp list --display-name $SERVICEPRINCIPAL_NAME --query "[].{id:objectId}" -o tsv)

echo "Give $SERVICEPRINCIPAL_NAME access to $KV_NAME Key Vault..."
az keyvault set-policy --name $KV_NAME --object-id "$SP_OBJ_ID" --secret-permissions get list set

echo "KV access applied"

# Give SP access to Container
echo "Give $SERVICEPRINCIPAL_NAME access to $TF_STATE_CONTAINER_NAME..."
az role assignment create \
    --role "Storage Blob Data Contributor" \
    --assignee-object-id "$SP_OBJ_ID" \
    --assignee-principal-type ServicePrincipal \
    --scope "/subscriptions/$SUBSCRIPTION/resourceGroups/$RG_SECRET_NAME/providers/Microsoft.Storage/storageAccounts/$TF_STATE_STORAGE_ACCOUNT_NAME/blobServices/default/containers/$TF_STATE_CONTAINER_NAME"

echo "Container access applied"

# Store .envrc information into Key Vault
APP_ID=$(az ad sp list --display-name $SERVICEPRINCIPAL_NAME --query [].{id:appId} -o tsv)

az keyvault secret set --name "ARM-CLIENT-ID" --value "$APP_ID" --vault-name $KV_NAME
az keyvault secret set --name "ARM-SUBSCRIPTION-ID" --value "$SUBSCRIPTION" --vault-name $KV_NAME
az keyvault secret set --name "ARM-TENANT-ID" --value "$TENANT" --vault-name $KV_NAME

# Output instructions
echo "Project Ready"
echo "Store this information into your .envrc file for Terraform:"
echo '"export ARM_CLIENT_ID=$(az keyvault secret show --name ARM-CLIENT-ID --vault-name '$KV_NAME' --query value -o tsv)"'
echo '"export ARM_CLIENT_SECRET=$(az keyvault secret show --name ARM-CLIENT-SECRET --vault-name '$KV_NAME' --query value -o tsv)"'
echo '"export ARM_SUBSCRIPTION_ID=$(az keyvault secret show --name ARM-SUBSCRIPTION-ID --vault-name '$KV_NAME' --query value -o tsv)"'
echo '"export ARM_TENANT_ID=$(az keyvault secret show --name ARM-TENANT-ID --vault-name '$KV_NAME' --query value -o tsv)"'