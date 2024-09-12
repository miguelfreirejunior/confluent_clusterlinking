module "porto_bastion" {
  source    = "./bastion"
  base_name = "bastion_porto"
  cidr      = var.aws_cidr
}

# Create Transit Gateway Attachment for the user's VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "attachment" {
  subnet_ids         = module.porto_bastion.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  vpc_id             = module.porto_bastion.vpc_id

  tags = {
    "Name" = "Vinculo da VPC Porto ao Gateway Porto"
  }
}

# Find the routing table
data "aws_route_tables" "rts" {
  depends_on = [ aws_ec2_transit_gateway_vpc_attachment.attachment ]
  vpc_id = module.porto_bastion.vpc_id
}

resource "aws_route" "vpc_to_porto" {
  for_each               = toset(data.aws_route_tables.rts.ids)
  route_table_id         = each.key
  destination_cidr_block = var.aws_tg_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway.id
}

resource "aws_route" "vpc_to_csu" {
  for_each               = toset(data.aws_route_tables.rts.ids)
  route_table_id         = each.key
  destination_cidr_block = var.aws_csu_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway.id
}

resource "aws_route" "vpc_to_csu_vpc" {
  for_each               = toset(data.aws_route_tables.rts.ids)
  route_table_id         = each.key
  destination_cidr_block = var.aws_vpc_csu_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway.id
}