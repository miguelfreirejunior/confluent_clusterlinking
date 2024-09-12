module "csu_bastion" {
  source    = "./bastion"
  base_name = "bastion_csu"
  cidr      = var.aws_vpc_csu_cidr
}

# Create Transit Gateway Attachment for the user's VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "csu_attachment" {
  subnet_ids         = module.csu_bastion.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway_csu.id
  vpc_id             = module.csu_bastion.vpc_id

  tags = {
    "Name" = "Vinculo da VPC CSU ao Gateway Csu"
  }
}

# Find the routing table
data "aws_route_tables" "csu_rts" {
  depends_on = [ aws_ec2_transit_gateway_vpc_attachment.csu_attachment ]
  vpc_id = module.csu_bastion.vpc_id
}

resource "aws_route" "csu_vpc_to_porto" {
  for_each               = toset(data.aws_route_tables.csu_rts.ids)
  route_table_id         = each.key
  destination_cidr_block = var.aws_tg_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway_csu.id
}

resource "aws_route" "csu_vpc_to_porto_vpc" {
  for_each               = toset(data.aws_route_tables.csu_rts.ids)
  route_table_id         = each.key
  destination_cidr_block = var.aws_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway_csu.id
}

resource "aws_route" "csu_vpc_to_csu" {
  for_each               = toset(data.aws_route_tables.csu_rts.ids)
  route_table_id         = each.key
  destination_cidr_block = var.aws_csu_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway_csu.id
}