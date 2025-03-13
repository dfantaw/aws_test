



# main.tf
provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
backend "s3"{
  bucket = "terraformstate1982"
  key    = "test/terraform.tfstate"
  region = "us-east-1"
}

}

# IAM Role for Elastic Beanstalk EC2 Instances
resource "aws_iam_role" "eb_ec2_role" {
  name = "aws-elasticbeanstalk-ec2-role-2"

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

resource "aws_s3_bucket" "react_bucket" { 
  bucket = "my-react-app-bucket-198-2"

  website { 
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-dotnet-app-bucket-198-2"
}

# Configure Block Public Access settings
resource "aws_s3_bucket_public_access_block" "react_bucket_access" {
  bucket = aws_s3_bucket.react_bucket.id

  # Disable Block Public Access settings
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Configure Block Public Access settings
resource "aws_s3_bucket_public_access_block" "react_app_bucket_access" {
  bucket = aws_s3_bucket.app_bucket.id

  # Disable Block Public Access settings
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy to allow public read access
resource "aws_s3_bucket_policy" "react_bucket_policy" {
  bucket = aws_s3_bucket.react_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.react_bucket.arn}/*"
      }
    ]
  })

depends_on = [aws_s3_bucket_public_access_block.react_bucket_access] # Ensures the block public access settings are applied first
}


# Bucket policy to allow public read access
resource "aws_s3_bucket_policy" "dotnet_app_bucket_policy" {
  bucket = aws_s3_bucket.app_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject","s3:PutObject"]
        Resource  = "${aws_s3_bucket.app_bucket.arn}/*"
      }
    ]
  })

depends_on = [aws_s3_bucket_public_access_block.react_bucket_access] # Ensures the block public access settings are applied first
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
  solution_stack_name = "64bit Amazon Linux 2 v2.8.8 running .NET Core"

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

output "s3_app_bucket_name"{
  value = aws_s3_bucket.app_bucket.bucket
}

output "elastic_beanstalk_name" {
  value = aws_elastic_beanstalk_environment.dotnet_env.name
}

