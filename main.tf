resource "aws_ecr_repository" "tasklist_repo" {
  name = "${var.app_name}-task-listing-repo"
}

resource "aws_elastic_beanstalk_application" "example_app" {
  name        = "${var.app_name}-task-listing-app"
  description = "Task listing app"
}

resource "aws_elastic_beanstalk_environment" "example_app_environment" {
  name                = "${var.app_name}-task-listing-app-environment"
  application         = aws_elastic_beanstalk_application.example_app.name

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

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "DB_USER"
    value = aws_db_instance.rds_app.username
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "DB_PASSWORD"
    value = var.db_password
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "DB_DATABASE"
    value = aws_db_instance.rds_app.db_name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "DB_HOST"
    value = aws_db_instance.rds_app.address
  }
} 

resource "aws_iam_instance_profile" "example_app_ec2_instance_profile" {
  name = "${var.app_name}-task-listing-app-ec2-instance-profile"
  role = aws_iam_role.example_app_ec2_role.name
}

resource "aws_iam_role" "example_app_ec2_role" {
  name = "${var.app_name}-task-listing-app-ec2-instance-role"
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

resource "aws_iam_role_policy_attachment" "policy_attachment_one" {
  role = aws_iam_role.example_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "policy_attachment_two" {
  role = aws_iam_role.example_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "policy_attachment_three" {
  role = aws_iam_role.example_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role = aws_iam_role.example_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_s3_bucket" "example" {
  bucket = "${var.app_name}-dockerrun"
}

resource "aws_db_instance" "rds_app" {
  allocated_storage    = 10
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  identifier           = "${var.app_name}-task-listing"
  db_name              = "${var.app_name}tasklistingdb"
  username             = "root"
  password             = var.db_password
  skip_final_snapshot  = true
  publicly_accessible  = true
}

