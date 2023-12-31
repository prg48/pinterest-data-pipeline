# filesets for notebooks
locals {
  batch-processing-notebooks = fileset("${path.module}/../../databricks-notebooks/batch-processing", "*.ipynb")
  stream-processing-notebooks = fileset("${path.module}/../../databricks-notebooks/stream-processing", "*.ipynb")
  queries-notebooks = fileset("${path.module}/../../databricks-notebooks/queries", "*.ipynb")
}

# upload notebooks
resource "databricks_notebook" "batch_processing" {
  for_each = { for nb in local.batch-processing-notebooks : nb => nb }

  provider = databricks.workspace
  source = "${path.module}/../../databricks-notebooks/batch-processing/${each.value}"
  path = "${data.databricks_current_user.me.home}/${each.value}"
}

resource "databricks_notebook" "stream_processing" {
  for_each = { for nb in local.stream-processing-notebooks : nb => nb }
  
  provider = databricks.workspace
  source = "${path.module}/../../databricks-notebooks/stream-processing/${each.value}"
  path = "${data.databricks_current_user.me.home}/${each.value}"
}

resource "databricks_notebook" "queries" {
  for_each = { for nb in local.queries-notebooks : nb => nb }
  
  provider = databricks.workspace
  source = "${path.module}/../../databricks-notebooks/queries/${each.value}"
  path = "${data.databricks_current_user.me.home}/${each.value}"
}