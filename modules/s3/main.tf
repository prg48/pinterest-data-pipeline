# create an S3 storage for batch-processing
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  force_destroy = var.force_destroy

  tags = {
    Name = "${var.bucket_name}"
    Environment = "${var.bucket_environment_name}"
  }
}

# block public access if block_public_access variable is true
resource "aws_s3_bucket_public_access_block" "bucket_public_access" {
  count = var.block_public_access ? 1 : 0

  bucket = aws_s3_bucket.bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# enable versioning if enable_bucket_versioning is true
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  count = var.enable_bucket_versioning ? 1 : 0

  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}