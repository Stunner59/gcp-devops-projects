variable "project_id" {
  description = "GCP Project Id"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-south1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  # default     = "my-vpc-network:"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
