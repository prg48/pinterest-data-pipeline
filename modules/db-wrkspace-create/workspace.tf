resource "databricks_mws_workspaces" "this" {
  provider = databricks.mws
  account_id = var.databricks_account_id
  aws_region = var.region
  workspace_name = var.workspace_name

  credentials_id = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id = databricks_mws_networks.this.network_id

  token {
    comment = "workspace from terraform"
  }
}

# # initialise databricks provider in normal workspace mode
# provider "databricks" {
#   alias = "workspace"
#   host = databricks_mws_workspaces.this.workspace_url
#   account_id = var.databricks_account_id
#   client_id = var.client_id
#   client_secret = var.client_secret
# }

# # create a personal access token
# resource "databricks_token" "pat" {
#   provider = databricks.workspace
#   comment = "Workspace provisioning"
#   lifetime_seconds = 604800 # 1 week
# }