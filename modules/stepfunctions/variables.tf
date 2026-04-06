variable "project" {
  description = "Project name"
  type        = string
}

variable "sfn_role_arn" {
  description = "ARN of the Step Functions IAM role"
  type        = string
}

variable "glue_job_name" {
  description = "Name of the Glue ETL job"
  type        = string
}

variable "raw_bucket_name" {
  description = "Name of the raw S3 bucket"
  type        = string
}

variable "processed_bucket_name" {
  description = "Name of the processed S3 bucket"
  type        = string
}
