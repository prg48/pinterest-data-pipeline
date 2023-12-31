# output kinesis streams' arns
output "kinesis_stream_arns" {
  value = module.kinesis.kinesis_stream_arns
}

# output the api gateway invoke url
output "api_gateway_invoke_url" {
  value = aws_api_gateway_stage.project_api_kinesis_stage.invoke_url
}