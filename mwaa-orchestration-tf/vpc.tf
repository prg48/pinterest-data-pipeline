# module "vpc" {
#   source = "cloudposse/vpc/aws"
#   version = "2.1.0"

#   ipv4_primary_cidr_block = "10.1.0.0/16"
#   context = module.this.context
# }

# module "subnets" {
#   source = "cloudposse/dynamic-subnets/aws"
#   version = "2.4.1"

#   availability_zones = data.aws_availability_zones.AZs.names
#   vpc_id = module.vpc.vpc_id
#   igw_id = [module.vpc.igw_id]
#   ipv4_cidr_block = [module.vpc.vpc_cidr_block]
#   nat_gateway_enabled = true
#   nat_instance_enabled = false

#   context = module.this.context
# }

# create a VPC for mwaa environment
locals {
  cidr = "10.1.0.0/16"
}

# # vpc for mwaa
# resource "aws_vpc" "vpc" {
#   cidr_block = "10.1.0.0/16"

#   tags = {
#     Name = "mwaa-vpc"
#   }
# }

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name = "mwaa-vpc"
  cidr = local.cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  create_igw = true

  enable_nat_gateway = true
  single_nat_gateway = true

  azs = data.aws_availability_zones.AZs.names
  private_subnets = [cidrsubnet(local.cidr, 3, 0), cidrsubnet(local.cidr, 3, 1)]
  public_subnets = [cidrsubnet(local.cidr, 3, 2), cidrsubnet(local.cidr, 3, 3)]

  manage_default_security_group = true
  default_security_group_name = "mwaa-sg"

  default_security_group_egress = [{
    cidr_blocks = "0.0.0.0/0"
  }]

  default_security_group_ingress = [{
    description = "allow all inbound tcp and udp"
    self = true
  }]

  tags = {
    Name = "mwaa-vpc"
  }
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.4.0"
  
  vpc_id = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_security_group_id]

  endpoints = {
    s3 = {
      service = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        module.vpc.private_route_table_ids,
        module.vpc.public_route_table_ids
      ])

    tags = {
        Name = "mwaa-vpc-s3-endpoint"
      }
    }

    # kms = {
    #   service = "kms"
    #   service_type = "Interface"
    #   private_dns_enabled = true
    #   subnet_ids = module.vpc.private_subnets
    #   security_group_ids = [module.vpc.default_security_group_id]
    #   tags = {
    #     Name = "mwaa-vpc-kms-endpoint"
    #   }
    # }

    # sqs = {
    #   service = "sqs"
    #   service_type = "Interface"
    #   private_dns_enabled = true
    #   subnet_ids = module.vpc.private_subnets
    #   security_group_ids = [module.vpc.default_security_group_id]
    #   tags = {
    #     Name = "mwaa-cpv-sqs-endpoint"
    #   }
    # }

    # logs = {
    #   service = "logs"
    #   service_type = "Interface"
    #   private_dns_enabled = true
    #   subnet_ids = module.vpc.private_subnets
    #   security_group_ids = [module.vpc.default_security_group_id]
    #   tags = {
    #     Name = "mwaa-vpc-logs-endpoint"
    #   }
    # }

    # ecr_api = {
    #   service = "ecr.api"
    #   service_type = "Interface"
    #   private_dns_enabled = true
    #   subnet_ids = module.vpc.private_subnets
    #   security_group_ids = [module.vpc.default_security_group_id]
    #   tags = {
    #     Name = "mwaa-vpc-ecr-api-endpoint"
    #   }
    # }

    # ecr_dkr = {
    #   service = "ecr.dkr"
    #   service_type = "Interface"
    #   private_dns_enabled = true
    #   subnet_ids = module.vpc.private_subnets
    #   security_group_ids = [module.vpc.default_security_group_id]
    #   tags = {
    #     Name = "mwaa-vpc-ecr-dkr-endpoint"
    #   }
    # }
  }
}