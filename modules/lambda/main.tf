# ── Zip the Lambda function code ─────────────────────────────────
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# ── Lambda Function ───────────────────────────────────────────────
resource "aws_lambda_function" "trigger_glue" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project}-trigger"
  role             = var.lambda_role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60

  environment {
    variables = {
      GLUE_JOB_NAME = var.glue_job_name
      SFN_ARN       = var.sfn_arn
    }
  }

  tags = {
    Project = var.project
  }
}

# ── Allow S3 to invoke Lambda ─────────────────────────────────────
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_glue.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.raw_bucket_arn
}

# ── S3 Event notification to trigger Lambda ───────────────────────
resource "aws_s3_bucket_notification" "raw_trigger" {
  bucket = var.raw_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.trigger_glue.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
