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

# variable for cidr block
variable "cidr_block" {
  description = "The cidr block for databricks"
  type = string
}

# variable for databricks client id
variable "client_id" {
  description = "The client id for databricks account"
  type = string
}

# variable for databricks client secret
variable "client_secret" {
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