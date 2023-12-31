# write the notebook paths for batch processing notebooks after they are uploaded to databricks
resource "local_file" "notebook_paths_file" {
  content  = join("\n", module.workspace_mgmt.batch_processing_notebook_paths)
  filename = "${path.root}/batch-processing-notebook-paths.txt"
}

resource "local_file" "cluster_path_file" {
  content = module.workspace_mgmt.cluster_id
  filename = "${path.root}/cluster-id.txt"
}