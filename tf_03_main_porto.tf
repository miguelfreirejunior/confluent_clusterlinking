
resource "aws_ec2_transit_gateway" "transit_gateway" {
  description                     = "Porto Transit Gateway"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  tags = {
    "Name" = "Porto Transit Gateway"
  }
}

resource "confluent_environment" "porto" {
  stream_governance {
    package = "ESSENTIALS"
  }
  display_name = "non-productive"
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Sharing Transit Gateway with Confluent via Resource Access Manager (RAM) Resource Share
resource "aws_ram_resource_share" "porto" {
  name                      = "resource-share-with-confluent"
  allow_external_principals = true
}

resource "aws_ram_resource_association" "porto" {
  resource_arn       = aws_ec2_transit_gateway.transit_gateway.arn
  resource_share_arn = aws_ram_resource_share.porto.arn
}

module "porto_cluster" {
  depends_on             = [aws_ram_resource_association.porto]
  source                 = "./transitGatewayCluster"
  aws_regiao             = var.aws_regiao_conta
  confluent_environment  = confluent_environment.porto.id
  confluent_network_cidr = var.aws_tg_cidr
  transit_gateway        = aws_ec2_transit_gateway.transit_gateway.id
  ram_resource_share_arn = aws_ram_resource_share.porto.arn
}