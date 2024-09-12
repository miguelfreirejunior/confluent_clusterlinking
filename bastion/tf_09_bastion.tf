data "aws_availability_zones" "available" {}

resource "aws_vpc" "shared_vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = "${var.base_name} Kafka Entry VPC"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.shared_vpc.id
  cidr_block              = cidrsubnet(var.cidr, 8, count.index + 1)
  map_public_ip_on_launch = false # This makes private subnet
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    "Name" = "tg_private-subnet${var.base_name}-${count.index}"
  }
}

resource "aws_default_route_table" "private_route_table" {
  default_route_table_id = aws_vpc.shared_vpc.default_route_table_id
  tags = {
    "Name" = "${var.base_name} Private Route Table"
  }
}

locals {
  public_sn_count = 2
}

resource "aws_subnet" "public_subnet" {
  count                   = local.public_sn_count
  vpc_id                  = aws_vpc.shared_vpc.id
  cidr_block              = cidrsubnet(var.cidr, 8, count.index + 3)
  map_public_ip_on_launch = true # This makes public subnet
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    "Name" = "${var.base_name} tg_public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.shared_vpc.id

  tags = {
    "Name" = "${var.base_name} Public Route"
  }
}

resource "aws_route_table_association" "public_association" {
  count          = local.public_sn_count
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.shared_vpc.id
  tags = {
    Name = "${var.base_name} VPC-IGW"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tf_key_pair" {
  key_name   = "${var.base_name}_Demoss"
  public_key = tls_private_key.tls_key.public_key_openssh
  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.tls_key.private_key_pem}' > ${var.base_name}_myKey.pem"
  }
}

module "vpc_a_ec2_bastion" {
  source    = "../compute"
  vpc_id    = aws_vpc.shared_vpc.id
  subnet_id = aws_subnet.public_subnet[0].id
  ec2_name  = "${var.base_name} Bastion Host"
  key_name  = aws_key_pair.tf_key_pair.key_name
  #instance_profile = module.iam_sqs.sqs_ec2_instance_profile_name
}

# # Create Transit Gateway Attachment for the user's VPC
# resource "aws_ec2_transit_gateway_vpc_attachment" "attachment" {
#   subnet_ids         = aws_subnet.private_subnet.*.id
#   transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
#   vpc_id             = aws_vpc.shared_vpc.id
# }

# # Find the routing table
# data "aws_route_tables" "rts" {
#   vpc_id = aws_vpc.shared_vpc.id
# }

# resource "aws_route" "vpc_to_porto" {
#   for_each               = toset(data.aws_route_tables.rts.ids)
#   route_table_id         = each.key
#   # route_table_id         = aws_default_route_table.private_route_table.id
#   destination_cidr_block = var.aws_tg_cidr
#   transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway.id
# }

# resource "aws_route" "vpc_to_csu" {
#   for_each               = toset(data.aws_route_tables.rts.ids)
#   route_table_id         = each.key
#   # route_table_id         = aws_default_route_table.private_route_table.id
#   destination_cidr_block = var.aws_csu_cidr
#   transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway.id
# }