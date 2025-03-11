# main.tf
provider "aws" {
  region = "us-east-1"
}

# IAM Role for Elastic Beanstalk EC2 Instances
resource "aws_iam_role" "eb_ec2_role" {
  name = "aws-elasticbeanstalk-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to the EC2 role
resource "aws_iam_role_policy_attachment" "eb_ec2_policy" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

# IAM Instance Profile for EC2 Instances
resource "aws_iam_instance_profile" "eb_ec2_profile" {
  name = "aws-elasticbeanstalk-ec2-profile"
  role = aws_iam_role.eb_ec2_role.name
}

# S3 Bucket for React App
resource "aws_s3_bucket" "react_bucket" {
  bucket = "my-react-app-bucket-1982" # Replace with your desired bucket name
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html" # Single-page app (SPA) fallback
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-react-app-bucket-1982/*"
    }
  ]
}
EOF
}

# Elastic Beanstalk Application for .NET Core App
resource "aws_elastic_beanstalk_application" "dotnet_app" {
  name        = "my-dotnet-app"
  description = "My .NET Core application"
}

# Elastic Beanstalk Environment for .NET Core App
resource "aws_elastic_beanstalk_environment" "dotnet_env" {
  name                = "my-dotnet-env"
  application         = aws_elastic_beanstalk_application.dotnet_app.name
  solution_stack_name = "64bit Amazon Linux 2 v2.5.8 running .NET Core"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_ec2_profile.name
  }
}

# Outputs
output "s3_bucket_name" {
  value = aws_s3_bucket.react_bucket.bucket
}

output "s3_bucket_website_endpoint" {
  value = aws_s3_bucket.react_bucket.website_endpoint
}

output "elastic_beanstalk_endpoint" {
  value = aws_elastic_beanstalk_environment.dotnet_env.endpoint_url
}