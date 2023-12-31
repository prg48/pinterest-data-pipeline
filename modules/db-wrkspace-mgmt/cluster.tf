resource "databricks_cluster" "this" {
  provider = databricks.workspace
  cluster_name = var.cluster_name
  spark_version = data.databricks_spark_version.latest.id
  node_type_id = data.databricks_node_type.smallest.id
  autotermination_minutes = 20
  num_workers = 1
}