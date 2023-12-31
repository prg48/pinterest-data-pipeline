# variable for AWS region
variable "region" {
  description = "Please provide the region in AWS in which to setup Databrickcs"
  type = string
}

# variable for databricks account id
variable "databricks_account_id" {
  description = "Please enter the account id for databricks"
  type = string
}

# variable for databricks client id
variable "databricks_client_id" {
  description = "The client id for databricks account"
  type = string
}

# variable for databricks client secret
variable "databricks_client_secret" {
  description = "The client secret for databricks account"
  type = string
}

# variable for databricks file system root s3 bucket
variable "databricks_root_bucket_name" {
  description = "Unique bucket name for the DBFS storage"
  type = string
}

# variable for name for the workspace
variable "workspace_name" {
  description = "The name for the databricks workspace"
  type = string
}

# variable for AWs access key id and secret access key for s3 bucket mounting purposes
variable "aws_access_key_id" {
  description = "The access key id for AWS"
  type = string
}

variable "aws_secret_access_key" {
  description = "The secret access key for AWs"
  type = string
}

# s3 bucket name variable that is to be mounted on databricks
variable "s3_mount_bucket_name" {
  description = "The s3 bucket to be mounted to databricks for data processing"
  type = string
}