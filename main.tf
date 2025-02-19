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

resource "aws_elastic_beanstalk_application" "example_app" {
  name        = "maltamash-task-listing-app"
  description = "Task listing app"
}

resource "aws_elastic_beanstalk_environment" "example_app_environment" {
  name                = "maltamash-task-listing-app-environment"
  application         = aws_elastic_beanstalk_application.example_app.name

  # This page lists the supported platforms
  # we can use for this argument:
  # https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html#platforms-supported.docker
  solution_stack_name = "64bit Amazon Linux 2023 v4.0.1 running Docker"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.example_app_ec2_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "EC2KeyName"
    value = "maltamash-keypair"
  }
} 

resource "aws_iam_instance_profile" "example_app_ec2_instance_profile" {
  name = "maltamash-task-listing-app-ec2-instance-profile"
  role = aws_iam_role.example_app_ec2_role.name
}
resource "aws_iam_role" "example_app_ec2_role" {
  name = "maltamash-task-listing-app-ec2-instance-role"
  // Allows the EC2 instances in our EB environment to assume (take on) this 
  // role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "sts:AssumeRole"
            Principal = {
               Service = "ec2.amazonaws.com"
            }
            Effect = "Allow"
            Sid = ""
        }
    ]
  })
}