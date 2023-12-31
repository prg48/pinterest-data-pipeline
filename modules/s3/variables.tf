# variable for s3 bucket name
variable "bucket_name" {
  description = "Bucket name for S3 bucket"
  type = string
}

# variable for bucket environment name
variable "bucket_environment_name" {
  description = "Bucket environment name for S3 bucket"
  type = string
}

# variable if we want to destroy the buckets even if it not empty
variable "force_destroy" {
  description = "true if we want to destroy the bucket even if it has contents, false otherwise"
  type = bool
  default = false
}

# variable to block public access 
variable "block_public_access" {
  description = "true if we want to block public access, false otherwise"
  type = bool
  default = false
}

# variable to enable bucket versioning
variable "enable_bucket_versioning" {
  description = "true if we want to enable bucket versioning, false otherwise"
  type = bool
  default = false
}