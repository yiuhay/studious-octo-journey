Using direnv
```
export ARM_TENANT_ID=$(az keyvault secret show --name ARM-TENANT-ID --vault-name <KEYVAULT> --query value -o tsv)
export ARM_CLIENT_ID=$(az keyvault secret show --name ARM-CLIENT-ID --vault-name <KEYVAULT> --query value -o tsv)
export ARM_CLIENT_SECRET=$(az keyvault secret show --name ARM-CLIENT-SECRET --vault-name <KEYVAULT> --query value -o tsv)
export ARM_SUBSCRIPTION_ID=$(az keyvault secret show --name ARM-SUBSCRIPTION-ID --vault-name <KEYVAULT> --query value -o tsv)
export ARM_ACCESS_KEY=$(az keyvault secret show --name ARM_ACCESS_KEY --vault-name <KEYVAULT> --query value -o tsv)
```

Prerequisites:
Script was ran and using output in direnv
`../script/project-bootstrap.sh`