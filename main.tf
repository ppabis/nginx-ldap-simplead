terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = ">= 4.2.0"

  name       = "main-vpc"
  cidr_block = var.vpc_cidr
  az_count   = 2

  subnets = {
    public = {
      netmask = 24
    }
    private = {
      netmask = 24
    }
  }
}
