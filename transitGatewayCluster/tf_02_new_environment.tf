resource "confluent_network" "transit_gateway" {
  display_name     = "aws-dedicated-transitgateway"
  cloud            = "AWS"
  region           = var.aws_regiao
  cidr             = var.confluent_network_cidr
  connection_types = ["TRANSITGATEWAY"]
  environment {
    id = var.confluent_environment
  }
}

resource "aws_ram_principal_association" "confluent" {
  principal          = confluent_network.transit_gateway.aws[0].account
  resource_share_arn = var.ram_resource_share_arn
}

resource "confluent_transit_gateway_attachment" "aws" {
  display_name = "AWS Transit Gateway Attachment"
  aws {
    ram_resource_share_arn = var.ram_resource_share_arn
    transit_gateway_id     = var.transit_gateway
    routes                 = var.routes
  }
  environment {
    id = var.confluent_environment
  }
  network {
    id = confluent_network.transit_gateway.id
  }
}

# Accepter's side of the connection.
data "aws_ec2_transit_gateway_vpc_attachment" "accepter" {
  id = confluent_transit_gateway_attachment.aws.aws[0].transit_gateway_attachment_id
}

# Accept Transit Gateway Attachment from Confluent
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "accepter" {
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_vpc_attachment.accepter.id
}

resource "confluent_kafka_cluster" "transit_gateway" {
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = var.aws_regiao
  environment {
    id = var.confluent_environment
  }
  network {
    id = confluent_network.transit_gateway.id
  }
  dedicated {
    cku = 1
  }
  display_name = "tg_canada_cluster"
  # lifecycle {
  #   prevent_destroy = true
  # }
}