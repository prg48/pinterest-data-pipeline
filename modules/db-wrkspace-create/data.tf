# role policy
data "databricks_aws_assume_role_policy" "this" {
  external_id = var.databricks_account_id
}

# crossaccount policy
data "databricks_aws_crossaccount_policy" "this"{}

# available zones
data "aws_availability_zones" "available" {}

# policy for s3 bucket
data "databricks_aws_bucket_policy" "this"{
    bucket = aws_s3_bucket.root_storage_bucket.bucket
}