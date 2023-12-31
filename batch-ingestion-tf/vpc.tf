locals {
  cidr = "10.0.0.0/16"
}

module "ingestion_vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.4.0"

    name = "ingestion_vpc"
    cidr = local.cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    create_igw = true

    azs = data.aws_availability_zones.AZs.names
    private_subnets = [
        cidrsubnet(local.cidr, 8, 0),
        cidrsubnet(local.cidr, 8, 1),
        cidrsubnet(local.cidr, 8, 2),
        cidrsubnet(local.cidr, 8, 3)
    ]
    public_subnets = [cidrsubnet(local.cidr, 8, 4)]

    public_subnet_tags = {
        "Name" = "ingestion_vpc-public"
        "map_public_ip_on_launch" = "true"
    }

    manage_default_security_group = true
    default_security_group_name = "batch-ingestion-sg"

    default_security_group_egress = [{
        cidr_blocks = "0.0.0.0/0"
    }]

    default_security_group_ingress = [{
        description = "Allow all tcp and udp traffic"
        self = true
    }]

    tags = {
        Name = "ingestion_vpc"
    }    
}

module "vpc_s3_endpoint" {
    source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
    version = "5.4.0"

    vpc_id = module.ingestion_vpc.vpc_id
    security_group_ids = [module.ingestion_vpc.default_security_group_id]

    endpoints = {
        s3 = {
            service = "s3"
            service_type = "Gateway"
            route_table_ids = flatten([
                module.ingestion_vpc.private_route_table_ids,
                module.ingestion_vpc.public_route_table_ids
            ])

            tags = {
                Name = "ingestion-vps-s3-endpoint"
            }
        }
    }
}