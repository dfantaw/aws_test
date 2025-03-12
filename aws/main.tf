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


output "s3_bucket_name" {
  value = "This is the name of the created s3 bucket name"
}
