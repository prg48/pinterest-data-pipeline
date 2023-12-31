# create api for kafka REST proxy integration with a template
resource "aws_api_gateway_rest_api" "project_api" {
  name = "project_api_kafka"
  description = "Kafka REST Proxy Integration API"
  body = templatefile("${path.root}/open-api-templates/kafka-client-integration.tpl", {
    public_ip = aws_instance.kafka_client_instance.public_ip
  })
}

# deploy the project api
resource "aws_api_gateway_deployment" "project_api_deployment" {
  depends_on = [
    aws_api_gateway_rest_api.project_api
  ]

  rest_api_id = aws_api_gateway_rest_api.project_api.id

  lifecycle {
    create_before_destroy = true
  }
}

# create a stage for the deployment
resource "aws_api_gateway_stage" "project_api_stage" {
  deployment_id = aws_api_gateway_deployment.project_api_deployment.id
  rest_api_id = aws_api_gateway_rest_api.project_api.id
  stage_name = "prod"
}