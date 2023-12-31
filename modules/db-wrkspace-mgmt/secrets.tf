# secret scope
resource "databricks_secret_scope" "aws" {
  provider = databricks.workspace
  name = "aws"
}

# add aws access key id
resource "databricks_secret" "access_key_id" {
  provider = databricks.workspace
  key = "access_key_id"
  string_value = var.aws_access_key_id
  scope = databricks_secret_scope.aws.id
}

# add aws secret access key
resource "databricks_secret" "secret_access_key" {
  provider = databricks.workspace
  key = "secret_access_key"
  string_value = var.aws_secret_access_key
  scope = databricks_secret_scope.aws.id
}

# add s3 mount bucket name
resource "databricks_secret" "s3_bucket" {
  provider = databricks.workspace
  key = "s3_mount_bucket_name"
  string_value = var.s3_mount_bucket_name
  scope = databricks_secret_scope.aws.id
}

# add aws region
resource "databricks_secret" "region" {
  provider = databricks.workspace
  key = "region"
  string_value = var.aws_region
  scope = databricks_secret_scope.aws.id
}