# create a databricks workspace
module "workspace_provision" {
  source = "../modules/db-wrkspace-create"
  region = var.region
  databricks_account_id = var.databricks_account_id
  cidr_block = "10.4.0.0/16"
  client_id = var.databricks_client_id
  client_secret = var.databricks_client_secret
  databricks_root_bucket_name = var.databricks_root_bucket_name
  workspace_name = var.workspace_name

  providers = {
    databricks.mws = databricks.mws
  }
}

# some delay
resource "null_resource" "delay" {
  depends_on = [ module.workspace_provision ]

  provisioner "local-exec" {
    command = "sleep 120"
  }
}

# create clusters, add notebooks, secrets etc
module "workspace_mgmt" {
  source = "../modules/db-wrkspace-mgmt"
  databricks_host = module.workspace_provision.databricks_host
  databricks_token = module.workspace_provision.databricks_token
  cluster_name = "pinterest-cluster"
  aws_access_key_id = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  s3_mount_bucket_name = var.s3_mount_bucket_name
  aws_region = var.region

  providers = {
    databricks.workspace = databricks.workspace
  }

  depends_on = [ 
    module.workspace_provision,
    null_resource.delay 
  ]
}