output "glue_role_arn" {
  description = "ARN of the Glue IAM role"
  value       = aws_iam_role.glue_role.arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}

output "sfn_role_arn" {
  description = "ARN of the Step Functions IAM role"
  value       = aws_iam_role.sfn_role.arn
}
