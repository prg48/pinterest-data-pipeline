# create a s3 bucket
module "s3" {
  source = "../modules/s3"
  bucket_name = var.bucket_name
  bucket_environment_name = "dev"
  force_destroy = true
}

# upload the local confluent sink connector to S3
resource "aws_s3_object" "s3_sink_connector" {
  bucket = module.s3.bucket_name
  key = "confluentinc-kafka-connect-s3-10.5.4.zip"
  source = "${path.root}/msk-connectors/confluentinc-kafka-connect-s3-10.5.4.zip"
}