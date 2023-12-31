##################### DBFS (databricks file system) SETUP ##############
# create a bucket
resource "aws_s3_bucket" "root_storage_bucket" {
  bucket = var.databricks_root_bucket_name
  # acl = "private"
  force_destroy = true
  tags = {
    Name = "${var.databricks_root_bucket_name}"

  }
}

# bucket ownership control
resource "aws_s3_bucket_ownership_controls" "root_storage_bucket_ownership" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

# private acl
resource "aws_s3_bucket_acl" "root_storage_bucket" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  acl = "private"
  depends_on = [ aws_s3_bucket_ownership_controls.root_storage_bucket_ownership ]
}

# server side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "root_storage_bucket" {
  bucket = aws_s3_bucket.root_storage_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# block public access
resource "aws_s3_bucket_public_access_block" "root_storage_bucket" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
  depends_on = [ aws_s3_bucket.root_storage_bucket ]
}

resource "aws_s3_bucket_policy" "root_bucket_policy" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  policy = data.databricks_aws_bucket_policy.this.json
  depends_on = [ 
    aws_s3_bucket_public_access_block.root_storage_bucket]
}

# disable bucket versioning
resource "aws_s3_bucket_versioning" "root_bucket_versioning" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

# storage configuration
resource "databricks_mws_storage_configurations" "this" {
  provider = databricks.mws
  account_id = var.databricks_account_id
  bucket_name = aws_s3_bucket.root_storage_bucket.bucket
  storage_configuration_name = "databricks-storage"
}
