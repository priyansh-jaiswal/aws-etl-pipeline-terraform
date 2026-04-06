variable "project" {
  description = "Project name"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  type        = string
}

variable "glue_job_name" {
  description = "Name of the Glue ETL job to trigger"
  type        = string
}

variable "raw_bucket_name" {
  description = "Name of the raw S3 bucket"
  type        = string
}

variable "raw_bucket_arn" {
  description = "ARN of the raw S3 bucket"
  type        = string
}

variable "sfn_arn" {
  description = "ARN of the Step Functions state machine"
  type        = string
}
