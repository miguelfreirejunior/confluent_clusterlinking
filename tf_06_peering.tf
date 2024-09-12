## Peering by Region - https://github.com/hashicorp/terraform-provider-aws/blob/main/examples/transit-gateway-intra-region-peering/main.tf
## Peering by Organizations - https://github.com/hashicorp/terraform-provider-aws/blob/main/examples/transit-gateway-cross-account-peering-attachment/main.tf

# Create the Peering attachment in the second account...
resource "aws_ec2_transit_gateway_peering_attachment" "creator_side" {
  # provider = aws.second

  # peer_account_id         = data.aws_caller_identity.first.account_id
  peer_region = var.aws_regiao_csu
  //var.aws_first_region
  transit_gateway_id      = aws_ec2_transit_gateway.transit_gateway.id
  peer_transit_gateway_id = aws_ec2_transit_gateway.transit_gateway_csu.id
  tags = {
    Name = "Peering lado porto"
    Side = "Creator"
  }
}

data "aws_ec2_transit_gateway_peering_attachment" "peering_side" {
  # provider = aws.first
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.transit_gateway_csu.id]
  }
  depends_on = [aws_ec2_transit_gateway_peering_attachment.creator_side]
}

# ...and accept it in the first account.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "peering_side" {
  # provider = aws.first

  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_peering_attachment.peering_side.id
  tags = {
    Name = "Peering lado CSU"
    Side = "Acceptor"
  }
}

data "aws_ec2_transit_gateway_route_table" "transit_gateway" {
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }

  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.transit_gateway.id]
  }
}

resource "aws_ec2_transit_gateway_route" "route_porto_csu" {
  destination_cidr_block = var.aws_csu_cidr

  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.transit_gateway.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.creator_side.id
}

resource "aws_ec2_transit_gateway_route" "route_porto_csu_vpc" {
  destination_cidr_block = var.aws_vpc_csu_cidr

  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.transit_gateway.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.creator_side.id
}

data "aws_ec2_transit_gateway_route_table" "transit_gateway_csu" {
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }

  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.transit_gateway_csu.id]
  }
}

resource "aws_ec2_transit_gateway_route" "route_csu_porto" {
  destination_cidr_block = var.aws_tg_cidr

  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.transit_gateway_csu.id
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_peering_attachment.peering_side.id
}

resource "aws_ec2_transit_gateway_route" "route_csu_porto_vpc" {
  destination_cidr_block = var.aws_cidr

  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.transit_gateway_csu.id
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_peering_attachment.peering_side.id
}