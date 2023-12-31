# output for kafka client instance public IP
output "kafka_client_public_ip" {
  value = aws_instance.kafka_client_instance.public_ip
}

# msk cluster broker string
output "msk_bootstrap_server_string" {
  value = aws_msk_cluster.msk_cluster.bootstrap_brokers
}

# API gateway invoke url
output "api_gateway_invoke_url" {
  value = aws_api_gateway_stage.project_api_stage.invoke_url
}