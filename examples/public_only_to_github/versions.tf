terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.2"
    }
    github = {
      source  = "integrations/github"
      version = "~>4.0"
    }
  }
  required_version = ">= 0.13"
}
