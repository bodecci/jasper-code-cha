// Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

// Configure the AWS Provider, specify region where the resources will be created.
provider "aws" {
  region = var.aws_region
}

