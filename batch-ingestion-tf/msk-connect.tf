############## MSK connect resources ####################
# create a custom plugin
resource "aws_mskconnect_custom_plugin" "s3_connector_plugin" {
  name = "s3-connector-plugin"
  content_type = "ZIP"

  location {
    s3{
      bucket_arn = data.aws_s3_bucket.storage.arn
      file_key = "confluentinc-kafka-connect-s3-10.5.4.zip"
    }
  }
  description = "Custom S3 sink connector for MSK Connect"
}

# cloudwatch log group for s3_connector
resource "aws_cloudwatch_log_group" "s3_connector_logs" {
  name = "s3_connector_logs"
  retention_in_days = 1
}

# create a custom connector with the s3_connector_plugin
resource "aws_mskconnect_connector" "s3_connector" {
  name = "s3-connector"

  kafkaconnect_version = "2.7.1"

  capacity {
    autoscaling {
      mcu_count = 1
      min_worker_count = 1
      max_worker_count = 2

      scale_in_policy {
        cpu_utilization_percentage = 40
      }

      scale_out_policy {
        cpu_utilization_percentage = 90
      }
    }
  }

  connector_configuration = {
    "connector.class" = "io.confluent.connect.s3.S3SinkConnector"
    "s3.region" = "${var.region}"
    "flush.size" = 1
    "schema.compatibility" = "NONE"
    "tasks.max" = 2
    "topics" = "0e3bbd435bfb.geo,0e3bbd435bfb.pin,0e3bbd435bfb.user"
    "format.class" = "io.confluent.connect.s3.format.json.JsonFormat"
    "partitioner.class" = "io.confluent.connect.storage.partitioner.DefaultPartitioner"
    "value.converter.schemas.enable" = "false"
    "value.converter" = "org.apache.kafka.connect.json.JsonConverter"
    "storage.class" = "io.confluent.connect.s3.storage.S3Storage"
    "key.converter" = "org.apache.kafka.connect.storage.StringConverter"
    "s3.bucket.name" = "${data.aws_s3_bucket.storage.bucket}"
  }

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = aws_msk_cluster.msk_cluster.bootstrap_brokers

      vpc {
        security_groups = [aws_security_group.msk_connect_security_group.id]
        subnets = [
          module.ingestion_vpc.private_subnets[2],
          module.ingestion_vpc.private_subnets[3]
          ]
      }
    }
  }

  kafka_cluster_client_authentication {
    authentication_type = "NONE"
  }

  kafka_cluster_encryption_in_transit {
    encryption_type = "PLAINTEXT"
  }

  log_delivery {
    worker_log_delivery {
      cloudwatch_logs {
        enabled = true
        log_group = aws_cloudwatch_log_group.s3_connector_logs.name
      }
    }
  }

  plugin {
    custom_plugin {
      arn = aws_mskconnect_custom_plugin.s3_connector_plugin.arn
      revision = 1
    }
  }

  timeouts {
    create = "40m"
  }

  service_execution_role_arn = aws_iam_role.msk_connect_role.arn
}