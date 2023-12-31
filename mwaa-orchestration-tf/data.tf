# caller identity
data "aws_caller_identity" "me" {}

# availability zones
data "aws_availability_zones" "AZs" {
  state = "available"
}