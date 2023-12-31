# get the policy that allows full access to kinesis
data "aws_iam_policy" "kinesis_access_policy" {
    arn = "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
}

# get the region 
data "aws_region" "current" {}