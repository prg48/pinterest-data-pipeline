# create an api
resource "aws_api_gateway_rest_api" "project_api_kinesis" {
  name = "project_api_kinesis"
  description = "Kinesis proxy integration API"
  body = templatefile("${path.root}/open-api-templates/kinesis-integration.tpl", {
    execution_role_arn = aws_iam_role.api_gateway_kinesis_access_role.arn,
    region = data.aws_region.current.name
  })
}

# deploy the api
resource "aws_api_gateway_deployment" "project_api_kinesis_deployment" {
  depends_on = [
    aws_api_gateway_rest_api.project_api_kinesis
  ]

  rest_api_id = aws_api_gateway_rest_api.project_api_kinesis.id

  lifecycle {
    create_before_destroy = true
  }
}

# create a stage for the deployment
resource "aws_api_gateway_stage" "project_api_kinesis_stage" {
  deployment_id = aws_api_gateway_deployment.project_api_kinesis_deployment.id
  rest_api_id = aws_api_gateway_rest_api.project_api_kinesis.id
  stage_name = "prod"
}