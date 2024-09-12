variable "base_name" {
  type        = string
  description = "Nome para distinguir os recursos"
}

variable "cidr" {
  type        = string
  default     = "10.30.0.0/16"
  description = "CIDR de rede a ser utilizado"
}