# variable for the dags S3 storage
variable "dag_storage" {
  description = "Please enter a unique value for S3 storage to store dags, requirements etc for Airflow"
  type = string
}

# region for AWS account
variable "region" {
  description = "Please enter the region for your AWS account"
  type = string
}

# mwaa environment name
variable "mwaa_env_name" {
  description = "name for mwaa environment"
  type = string
}