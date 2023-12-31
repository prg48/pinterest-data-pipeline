# create a role for api_gateway_kinesis_access_policy
resource "aws_iam_role" "api_gateway_kinesis_access_role" {
  name = "api_gateway_full_kinesis_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Effect = "Allow",
            Principal = {
                Service = "apigateway.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }
    ]
  })
}

# attach the kinesis_access_policy policy to the role
resource "aws_iam_role_policy_attachment" "kinesis_access_policy_to_role_attachment" {
    role = aws_iam_role.api_gateway_kinesis_access_role.name
    policy_arn = data.aws_iam_policy.kinesis_access_policy.arn
}