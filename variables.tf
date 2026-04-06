variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Project name used for naming all resources"
  type        = string
  default     = "ecommerce-etl"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
