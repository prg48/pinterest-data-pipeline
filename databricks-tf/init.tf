terraform {
  required_providers {
    databricks = {
        source = "databricks/databricks"
    }
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.15.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# provider initialisation for account level workspace creation
provider "databricks" {
  alias = "mws"
  host = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id
  client_id = var.databricks_client_id
  client_secret = var.databricks_client_secret
}

# provider initialisation for workspace level resource creation
provider "databricks" {
  alias = "workspace"
  host = module.workspace_provision.databricks_host
  token = module.workspace_provision.databricks_token
}