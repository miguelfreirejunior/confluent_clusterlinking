variable "confluent_network_cidr" {
  type        = string
  description = "CIDR de rede a ser utilizado pelo Confluent"
}

variable "aws_regiao" {
  type        = string
  default     = "ca-central-1"
  description = "Regiao onde os recursos serao alocados."
}

variable "confluent_environment" {
  type        = string
  description = "Environment à conter os novos recursos"
}

variable "ram_resource_share_arn" {
  type        = string
  description = "arn do Resource Share do Transit Gateway"
}

variable "transit_gateway" {
  type        = string
  description = "Id do Transit Gateway a ser vinculado para cluster linking"
}

variable "routes" {
  description = "The AWS VPC CIDR blocks or subsets. List of destination routes for traffic from Confluent VPC to your VPC via Transit Gateway."
  type        = list(string)
  default     = ["100.64.0.0/10", "10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
}

# variable "vpc_id" {
#   description = "The AWS VPC ID of the VPC that you're connecting with Confluent Cloud."
#   type        = string
# }