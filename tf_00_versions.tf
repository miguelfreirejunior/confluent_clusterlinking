terraform {
  required_version = ">= 0.14.0"

  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.1.0"
    }
  }
}