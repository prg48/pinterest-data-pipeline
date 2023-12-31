# create a kinesis datastream
resource "aws_kinesis_stream" "kinesis_stream" {
  count = length(var.names) == length(var.shard_counts) ? length(var.names) : 0
  name = var.names[count.index]
  shard_count = var.shard_counts[count.index]
  retention_period = 24
  enforce_consumer_deletion = true

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}