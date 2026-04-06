variable "project" {
  description = "Project name"
  type        = string
}

variable "glue_role_arn" {
  description = "ARN of the Glue IAM role"
  type        = string
}

variable "raw_bucket_name" {
  description = "Name of the raw S3 bucket"
  type        = string
}

variable "proc_bucket_name" {
  description = "Name of the processed S3 bucket"
  type        = string
}

variable "script_bucket_name" {
  description = "Name of the S3 bucket to store Glue script"
  type        = string
}
