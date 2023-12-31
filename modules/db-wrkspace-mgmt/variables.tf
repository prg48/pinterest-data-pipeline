# databricks workspace url
variable "databricks_host" {
  description = "The host URL for the databricks workspace"
  type = string
}

# databricks workspace token
variable "databricks_token" {
  description = "The token for the databricks host"
  type = string
  sensitive = true
}

# cluster name
variable "cluster_name" {
  description = "The name for the cluster"
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

# variable for aws region
variable "aws_region" {
  description = "The AWS region"
  type = string
}