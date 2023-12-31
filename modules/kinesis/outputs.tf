# list of kinesis stream arns
output "kinesis_stream_arns" {
  value = aws_kinesis_stream.kinesis_stream.*.arn
}