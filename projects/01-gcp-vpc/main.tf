terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "vpc" {
  source      = "./modules/vpc"
  project_id  = var.project_id
  vpc_name    = var.vpc_name
  region      = var.region
  environment = var.environment
}
