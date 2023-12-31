# write the api gateway invoke url to a local file
resource "local_file" "invoke_url" {
  content = aws_api_gateway_stage.project_api_stage.invoke_url
  filename = "${path.root}/kafka-invoke-url.txt"
}