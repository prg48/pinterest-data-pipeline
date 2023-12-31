# output the batch processing notebook paths
output "batch_processing_notebook_paths" {
  value = [for nb in values(databricks_notebook.batch_processing) : nb.path]
  description = "Paths for all batch processing notebooks"
}

# cluster id
output "cluster_id" {
  value = databricks_cluster.this.cluster_id
  description = "Cluster Id for databricks cluster"
}