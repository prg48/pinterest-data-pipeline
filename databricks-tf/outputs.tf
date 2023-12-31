# databricks workspace url
output "databricks_host" {
  value = module.workspace_provision.databricks_host
  description = "The workspace URL for the provisioned workspace"
}

# databricks workspace token
output "databricks_token" {
  value = module.workspace_provision.databricks_token
  sensitive = true
  description = "The token for the provisioned workspace"
}

# batch processing notebook paths
output "batch_processing_notebook_paths" {
  value = module.workspace_mgmt.batch_processing_notebook_paths
  description = "The paths for the batch processing notebooks in databricks"
}