#!/bin/bash

SUBSCRIPTION=
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
ACCOUNT_KEY=$(az storage account keys list --resource-group $RG_NAME --account-name $TF_STATE_STORAGE_ACCOUNT_NAME --query '[0]'.value -o tsv)

echo "Storage account key retrieved."

# Create a storage container (for the Terraform State)
echo "Creating $TF_STATE_CONTAINER_NAME storage container..."
az storage container create --name $TF_STATE_CONTAINER_NAME \
    --account-name $TF_STATE_STORAGE_ACCOUNT_NAME \
    --account-key $ACCOUNT_KEY \
    --public-access off

# Store the Terraform State Storage Key into KeyVault
echo "Store storage access key into key vault secret..."
az keyvault secret set --name angdevst-key --value $ACCOUNT_KEY --vault-name $KEYVAULT_NAME

echo "Key vault secret created."

# Generate random string for Service Principal
SP_SECRET=$(openssl rand -base64 64)

