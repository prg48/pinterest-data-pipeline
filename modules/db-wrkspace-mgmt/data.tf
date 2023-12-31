# m5d.large
data "databricks_node_type" "smallest" {
    provider = databricks.workspace
    local_disk = true
}

# spark 3.2.1
data "databricks_spark_version" "latest" {
    provider = databricks.workspace
    spark_version = "3.2.1"
}

# current user (principle server)
data "databricks_current_user" "me"{
    provider = databricks.workspace
}