**Demo for using Terragrunt / Azure Remote Backend**

Terragrunt does not support automatically create the backend infrastructure for Azure like AWS e.g. auto create S3 and DynamoDB

The `init-remote-state-backend.sh` script was ran to set up the backend.

Access key needs to be stored as a `ARM_ACCESS_KEY` environment variable