# variable for aws region
variable "region" {
  description = "Please enter the region for your AWS account"
  type = string
}

# unique bucket name that was created in ../batch-storage/s3.tf
variable "bucket_name"{
    description = "Please enter the S3 bucket name that was created in ../batch-storage.tf"
    type = string
}