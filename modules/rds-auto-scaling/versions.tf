terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0, < 5.29.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0, < 3.6.0"
    }
  }
}
