terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0, < 5.29.0"
    }
    // FIXME: Remove, refactor or change. (Template)
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}
