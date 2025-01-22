terraform {

  backend "s3" {
    bucket         = "joyanto-deploying-udemy-tf" # REPLACE WITH YOUR BUCKET NAME
    key            = "09-udemy/deploying-single-container/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "deployed-app" {
  source = "./deployed-app"

  cluster_name         = "my-terraform-cluster"
  task_def_family_name = "my-terraform-task"
}