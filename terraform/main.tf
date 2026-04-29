terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "my-terraform-state-1777049256"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "security" {
  source       = "./modules/security"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

module "eks" {
  source             = "./modules/eks"
  project_name       = var.project_name
  private_subnet_ids = module.vpc.private_subnet_ids
  app_sg_id          = module.security.app_sg_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

module "observability" {
  source           = "./modules/observability"
  project_name     = var.project_name
  eks_cluster_name = module.eks.cluster_name
  alert_email      = "ronnieharmon390@yahoo.com"
}

module "secrets" {
  source       = "./modules/secrets"
  project_name = var.project_name
}

output "secret_arn" {
  value = module.secrets.secret_arn
}