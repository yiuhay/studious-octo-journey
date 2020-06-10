#!/bin/bash

set -e

export SUBSCRIPTION=YOUR_SUBSCRIPTION
export LOCATION=UKSOUTH
export RG_NAME=YOUR_RESOURCE_GROUP_NAME
export TF_STATE_STORAGE_ACCOUNT_NAME=YOUR_STORAGE_ACCOUNT_NAME
export TF_STATE_CONTAINER_NAME=YOUR_STORAGE_CONTAINER_NAME
export KEYVAULT_NAME=YOUR_KEYVAULT_NAME
export SERVICEPRINCIPAL = YOUR_SERVICE_PRINCIPAL_ID

# Active subscription
az account set --subscription $SUBSCRIPTION

# Create the resource group
echo "Creating $RG_NAME resource group..."
az group create -n $RG_NAME -l $LOCATION

echo "Resource group $RG_NAME created."

# Create the storage account
echo "Creating $TF_STATE_STORAGE_ACCOUNT_NAME storage account..."
az storage account create -g $RG_NAME -l $LOCATION \
    --name $TF_STATE_STORAGE_ACCOUNT_NAME \
    --kind StorageV2 \
    --sku Standard_LRS \
    --encryption-services blob \
    --https-only true

echo "Storage account $TF_STATE_STORAGE_ACCOUNT_NAME created."

# Retrieve the storage account key
echo "Retrieving storage account key..."
ACCOUNT_KEY=$(az storage account keys list --resource-group $RG_NAME --account-name $TF_STATE_STORAGE_ACCOUNT_NAME --query '[0]'.value -o tsv)

echo "Storage account key retrieved."

# Create a storage container (for the Terraform State)
echo "Creating $TF_STATE_CONTAINER_NAME storage container..."
az storage container create --name $TF_STATE_CONTAINER_NAME \
    --account-name $TF_STATE_STORAGE_ACCOUNT_NAME \
    --account-key $ACCOUNT_KEY \
    --public-access off

echo "Storage container $TF_STATE_CONTAINER_NAME created."

# Create an Azure KeyVault
echo "Creating $KEYVAULT_NAME key vault..."
az keyvault create -g $RG_NAME -l $LOCATION --name $KEYVAULT_NAME --sku standard

echo "Key vault $KEYVAULT_NAME created."

# Store the Terraform State Storage Key into KeyVault
echo "Store storage access key into key vault secret..."
az keyvault secret set --name tfstate-storage-key --value $ACCOUNT_KEY --vault-name $KEYVAULT_NAME

echo "Key vault secret created."

# Grant Service Principal access to KeyVault
# Comment this out if you do not use SP
echo "Grant Service Principal access to key vault secret..."
az keyvault set-policy -n $KEYVAULT_NAME --spn $SERVICEPRINCIPAL --secret-permissions get list

echo "Key vault secret granted."

# Display information
echo "Azure Storage Account and KeyVault have been created."
echo "Run the following command to initialize Terraform to store its state into Azure Storage:"
echo "terraform init -backend-config=\"storage_account_name=$TF_STATE_STORAGE_ACCOUNT_NAME\" -backend-config=\"container_name=$TF_STATE_CONTAINER_NAME\" -backend-config=\"access_key=\$(az keyvault secret show --name tfstate-storage-key --vault-name $KEYVAULT_NAME --query value -o tsv)\" -backend-config=\"key=terraform-ref-architecture-tfstate\""
