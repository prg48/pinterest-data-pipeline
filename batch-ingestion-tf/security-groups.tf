################# Security groups for kafka client and MSK ####################
# security group for kafka client
resource "aws_security_group" "kafka_client_security_group" {
  name = "kafka_client_security_group"
  description = "Security group for kafka client"
  vpc_id = module.ingestion_vpc.vpc_id

  # inbound rules
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "incoming REST proxy api"
    from_port = 8082
    to_port = 8082
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound rules
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kafka_client_security_group"
  }
}

# security group for MSK
resource "aws_security_group" "msk_security_group" {
  name = "msk_security_group"
  description = "Security group for MSK cluster"
  vpc_id = module.ingestion_vpc.vpc_id

  # inbound rules
  ingress {
    description = "inter-broker communication"
    from_port = 9092
    to_port = 9092
    protocol = "tcp"
    self = true
  }

  # outbound rules
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "msk_security_group"
  }
}

# security group for msk connect s3 sink connector
resource "aws_security_group" "msk_connect_security_group" {
  name = "msk_connect_security_group"
  description = "Security group for msk connect custom S3 sink connector"
  vpc_id = module.ingestion_vpc.vpc_id

  # outbound rules
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# rules to allow inbound on port 9092 to kafka client from msk and vice versa
resource "aws_security_group_rule" "kafka_client_to_msk" {
  type              = "ingress"
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  security_group_id = aws_security_group.msk_security_group.id
  source_security_group_id = aws_security_group.kafka_client_security_group.id
  description = "Allow Kafka client to communicate with MSK on port 9092"
}

resource "aws_security_group_rule" "msk_to_kafka_client" {
  type              = "ingress"
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  security_group_id = aws_security_group.kafka_client_security_group.id
  source_security_group_id = aws_security_group.msk_security_group.id
  description = "Allow MSK to communicate with Kafka client on port 9092"
}

# rules to allow inbound on port 9092 to msk connector from msk and vice versa
resource "aws_security_group_rule" "msk_connect_to_msk" {
  type              = "ingress"
  from_port         = 9092  
  to_port           = 9092  
  protocol          = "tcp"
  security_group_id = aws_security_group.msk_security_group.id
  source_security_group_id = aws_security_group.msk_connect_security_group.id
  description       = "Allow MSK Connect to communicate with MSK on port 9092"
}

resource "aws_security_group_rule" "msk_to_msk_connect" {
  type              = "ingress"
  from_port         = 9092  
  to_port           = 9092  
  protocol          = "tcp"
  security_group_id = aws_security_group.msk_connect_security_group.id
  source_security_group_id = aws_security_group.msk_security_group.id
  description       = "Allow MSK to communicate with MSK Connect on port 9092"
}