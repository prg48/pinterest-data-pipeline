############## MSK resources ##################
# create a resource in cloudwatch to store logs from msk cluster
resource "aws_cloudwatch_log_group" "msk_cluster_logs" {
  name = "msk_cluster_logs"
  retention_in_days = 1
}

# create a KMS key for encryption at rest for the data in the cluster
resource "aws_kms_key" "msk_cluster_kms_key" {
  description = "key for msk cluster"
  deletion_window_in_days = 7
}

# create a msk cluster
resource "aws_msk_cluster" "msk_cluster" {
  cluster_name = "msk-cluster"
  kafka_version = "2.8.1"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type = "kafka.m5.large"
    client_subnets = [
        module.ingestion_vpc.private_subnets[0],
        module.ingestion_vpc.private_subnets[1]
    ]
    storage_info {
      ebs_storage_info {
        volume_size = 5
      }
    }
    security_groups = [aws_security_group.msk_security_group.id]
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "PLAINTEXT"
    }
    encryption_at_rest_kms_key_arn = aws_kms_key.msk_cluster_kms_key.arn
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled = true
        log_group = aws_cloudwatch_log_group.msk_cluster_logs.name
      }
    }
  }

  tags = {
    Name = "msk_cluster"
  }
}