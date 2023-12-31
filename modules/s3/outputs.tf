# bucket name
output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

# bucket arn
output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}