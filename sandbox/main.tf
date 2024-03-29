locals {
  region = "ap-south-1"
}
# terraform configurations
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = "4.20.1"
    }
  }
  backend "s3" {
    bucket = "tmp-tst-elastic-snap"
    key    = "dev/sandbox/terraform.tfstate"
    region = "ap-south-1"
  }
}

# provider configurations
provider "aws" {
  region = local.region
}

# calling tags module
module "tags" {
  # source = "git@github.com:Jay-solan/aws-infra-module.git//tags?ref=main"
  source = "../../aws-infra-module/tags"

  names = ["app-name", "dev", "frontend"]

  tags = {
    "Env"       = "Dev",
    "Namespace" = "frontend",
    "Owner"     = "Frontend Engineering Team"
  }
}

# creating ecr

module "ecr" {
  # source = "git@github.com:Jay-solan/aws-infra-module.git//ecr?ref=main"
  source = "../../aws-infra-module/ecr"
  name   = module.tags.name
  tags   = module.tags.tags

}

# creating infrastructure


module "infra" {
  # source = "git@github.com:Jay-solan/aws-infra-module.git//environment?ref=main"
  source = "../../aws-infra-module/environment"
  name   = module.tags.name
  name6  = module.tags.name6
  tags   = module.tags.tags
  region = local.region

  // VPC
  cidr            = "10.0.0.0/16"
  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  // ALB
  ami           = "ami-0f863d7367abe5d6f"
  instance_type = "t3.micro"

  //ECS
  service_name   = module.tags.name
  image = "${module.ecr.repo_url}/${module.tags.name}:latest"
  desired_count  = 2
  container_port = 80
  host_port = 80
}
