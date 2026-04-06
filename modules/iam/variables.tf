variable "project" {
  description = "Project name"
  type        = string
}

variable "raw_bucket_arn" {
  description = "ARN of the raw S3 bucket"
  type        = string
}

variable "proc_bucket_arn" {
  description = "ARN of the processed S3 bucket"
  type        = string
}
