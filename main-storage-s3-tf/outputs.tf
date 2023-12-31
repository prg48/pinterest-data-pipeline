# bucket name
output "bucket_name" {
  value = module.s3.bucket_name
}

# object s3 sink connector key
output "object_s3_sink_connector_key" {
  value = aws_s3_object.s3_sink_connector.key
}