output "raw_bucket_name" {
  description = "Name of the raw S3 bucket"
  value       = module.s3.raw_bucket_name
}

output "processed_bucket_name" {
  description = "Name of the processed S3 bucket"
  value       = module.s3.processed_bucket_name
}

output "glue_job_name" {
  description = "Name of the Glue ETL job"
  value       = module.glue.glue_job_name
}

output "lambda_function_name" {
  description = "Name of the Lambda trigger function"
  value       = module.lambda.lambda_function_name
}

output "step_function_arn" {
  description = "ARN of the Step Functions state machine"
  value       = module.stepfunctions.state_machine_arn
}
