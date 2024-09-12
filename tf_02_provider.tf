provider "confluent" {
  cloud_api_key    = var.confluent_cloud_credentials.key
  cloud_api_secret = var.confluent_cloud_credentials.secret
}

provider "confluent" {
  alias            = "csu"
  cloud_api_key    = var.csu_confluent_cloud_credentials.key
  cloud_api_secret = var.csu_confluent_cloud_credentials.secret
}

provider "aws" {
  profile = var.aws_profile
}