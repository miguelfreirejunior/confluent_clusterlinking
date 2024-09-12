variable "confluent_cloud_credentials" {
  description = "Credenciais para gerenciamento dos recursos genéricos da cloud confluent"
  type = object({
    key    = string
    secret = string
  })
  sensitive = true
}

variable "csu_confluent_cloud_credentials" {
  description = "Credenciais para gerenciamento dos recursos genéricos da cloud confluent"
  type = object({
    key    = string
    secret = string
  })
  sensitive = true
}

variable "aws_account_id" {
  type        = string
  description = "ID da conta (apenas numeros)."
}

variable "aws_profile" {
  type        = string
  description = "Profile de conexão"
}

variable "aws_regiao_conta" {
  type        = string
  default     = "ca-central-1"
  description = "Regiao onde os recursos serao alocados."
}

variable "aws_cidr" {
  type        = string
  default     = "10.30.0.0/16"
  description = "CIDR de rede a ser utilizado pelo Confluent"
}

variable "aws_tg_cidr" {
  type        = string
  default     = "10.31.0.0/16"
  description = "CIDR de rede a ser utilizado pela VPC do Transit Gateway"
}

variable "aws_csu_cidr" {
  type        = string
  default     = "10.32.0.0/16"
  description = "CIDR de rede a ser utilizado pela VPC da CSU"
}

variable "aws_vpc_csu_cidr" {
  type        = string
  default     = "10.33.0.0/16"
  description = "CIDR de rede a ser utilizado pela VPC da CSU"
}

variable "aws_regiao_csu" {
  type        = string
  default     = "ca-central-1"
  description = "Regiao onde os recursos serao alocados."
}