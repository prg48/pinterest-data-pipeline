# get the bucket data created with s3.tf in ../batch-storage-tf folder
data "aws_s3_bucket" "storage" {
  bucket = var.bucket_name
}

# availability zones
data "aws_availability_zones" "AZs" {
  state = "available"
}