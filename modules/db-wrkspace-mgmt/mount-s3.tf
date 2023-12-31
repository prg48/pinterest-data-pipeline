# # mount the s3 bucket to databricks workspace as soon as the cluster is up
# resource "databricks_job" "mount_s3_bucket" {
#   name = "Mount S3 bucket"
#   description = "Run the mount_s3_storage.ipynb notebook"
#   provider = databricks.workspace

#   task {
#     task_key = "mount"

#     existing_cluster_id = databricks_cluster.this.id

#     notebook_task {
#         notebook_path = "${data.databricks_current_user.me.home}/mount_s3_storage.ipynb"
#     }
#   }

#   depends_on = [ 
#     databricks_cluster.this,
#     databricks_notebook.batch_processing,
#     databricks_secret.access_key_id,
#     databricks_secret.secret_access_key,
#     databricks_secret.s3_bucket
#    ]
# }