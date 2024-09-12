resource "aws_ec2_transit_gateway" "transit_gateway_csu" {
  description                     = "CSU Transit Gateway"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  tags = {
    "Name" = "CSU Transit Gateway"
  }
}

resource "confluent_environment" "csu" {
  stream_governance {
    package = "ESSENTIALS"
  }
  display_name = "non-productive"
  provider     = confluent.csu
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Sharing Transit Gateway with Confluent via Resource Access Manager (RAM) Resource Share
resource "aws_ram_resource_share" "csu" {
  name                      = "resource-share-with-confluent"
  allow_external_principals = true
}

resource "aws_ram_resource_association" "csu" {
  resource_arn       = aws_ec2_transit_gateway.transit_gateway_csu.arn
  resource_share_arn = aws_ram_resource_share.csu.arn
}

module "csu_cluster" {
  depends_on             = [aws_ram_resource_association.csu]
  source                 = "./transitGatewayCluster"
  aws_regiao             = var.aws_regiao_csu
  confluent_environment  = confluent_environment.csu.id
  confluent_network_cidr = var.aws_csu_cidr
  transit_gateway        = aws_ec2_transit_gateway.transit_gateway_csu.id
  ram_resource_share_arn = aws_ram_resource_share.csu.arn

  providers = {
    confluent = confluent.csu
  }
}