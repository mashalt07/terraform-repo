terraform {
  backend "s3" {
    bucket = "maltamash-tf-state-bucket"
    key    = "statefile"
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

resource "aws_instance" "app_server" {
  ami           = "ami-0d26eb3972b7f8c96"
  instance_type = "t2.micro"
}