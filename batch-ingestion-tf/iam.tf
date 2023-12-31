## IAM for kafka client ##
# create IAM policy, role and role attachment for kafka client
resource "aws_iam_policy" "msk_access_policy" {
  name = "msk_access_policy"
  description = "Policy allows read/write access to MSK cluster"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:AlterCluster",
          "kafka-cluster:DescribeCluster"
        ],
        Resource = aws_msk_cluster.msk_cluster.arn
      },
      {
        Effect = "Allow",
        Action = [
          "kafka-cluster:*Topic*",
          "kafka-cluster:WriteData",
          "kafka-cluster:ReadData"
        ],
        Resource = aws_msk_cluster.msk_cluster.arn
      },
      {
        Effect = "Allow",
        Action = [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ],
        Resource = aws_msk_cluster.msk_cluster.arn
      }
    ]
  })
}

# create a role for kafka client
resource "aws_iam_role" "kafka_client_role" {
  name = "kafka_client_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        },
    ]
  })
}

# attach msk access policy to kafka client role
resource "aws_iam_role_policy_attachment" "msk_access_policy_to_role_attachment" {
  role = aws_iam_role.kafka_client_role.name
  policy_arn = aws_iam_policy.msk_access_policy.arn
}

## IAM for MSK connect ##
# create a policy that allows to write to an S3 bucket
resource "aws_iam_policy" "s3_access_policy" {
  name = "s3_access_policy"
  description = "Policy that allows s3 access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListAllMyBuckets"
        ],
        Resource = "arn:aws:s3:::*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${data.aws_s3_bucket.storage.bucket}",
          "arn:aws:s3:::${data.aws_s3_bucket.storage.bucket}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucketMultipartUploads"
        ],
        Resource = [
          "arn:aws:s3:::${data.aws_s3_bucket.storage.bucket}",
          "arn:aws:s3:::${data.aws_s3_bucket.storage.bucket}/*"
        ]
      },
    ]
  })
}

# create a role for msk connect
resource "aws_iam_role" "msk_connect_role" {
  name = "msk_connect_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "kafkaconnect.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# attach the s3 access policy to msk connect role
resource "aws_iam_role_policy_attachment" "s3_policy_to_msk_connect_role_attachment" {
  role = aws_iam_role.msk_connect_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn 
}
