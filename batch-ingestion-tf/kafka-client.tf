############## Kafka client resources ####################
# create an instance profile from kafka client role and attach to kafka client instance
resource "aws_iam_instance_profile" "kafka_client_to_msk_instance_profile" {
  name = "kafka_client_to_msk_instance_profile"
  role = aws_iam_role.kafka_client_role.name
}

# create a key pair for kafka_client instance
resource "aws_key_pair" "kafka_client_key_pair" {
  key_name   = "kafka-client-key-pair"
  public_key = file("${path.root}/kafka-client-key-pairs/kafka-client-key-pair.pub")

  tags = {
    Name = "kafka_client_key_pair"
  }
}

# create an EC2 instance for Kafka client
resource "aws_instance" "kafka_client_instance" {
  ami                    = "ami-0cfd0973db26b893b"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.kafka_client_key_pair.key_name
  subnet_id              = module.ingestion_vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.kafka_client_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.kafka_client_to_msk_instance_profile.name
  associate_public_ip_address = true

  tags = {
    Name = "kafka_client_instance"
  }
}