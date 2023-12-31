################# Outputs necessary for Ansible automation #################
# generate an ansible inventory file with the output of kafka_client_instance public_ip
resource "local_file" "ansible_inventory" {
  content = aws_instance.kafka_client_instance.public_ip
  filename = "${path.root}/ansible/inventory"
}

# generate an ansible bootstrap-server file with the output of msk_cluster bootstrap broker string
resource "local_file" "msk_cluster_bootstrap_brokers" {
  content = aws_msk_cluster.msk_cluster.bootstrap_brokers
  filename = "${path.root}/ansible/bootstrap-brokers"
}