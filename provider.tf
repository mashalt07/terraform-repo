terraform {
  backend "s3" {
    bucket = "maltamash-tf-state-bucket"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}