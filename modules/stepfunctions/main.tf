# ── Step Functions State Machine ──────────────────────────────────
resource "aws_sfn_state_machine" "etl_pipeline" {
  name     = "${var.project}-pipeline"
  role_arn = var.sfn_role_arn

  definition = jsonencode({
    Comment = "E-Commerce ETL Pipeline Orchestration"
    StartAt = "ValidateFile"

    States = {
      # ── Step 1: Validate the incoming file ──────────────────────
      ValidateFile = {
        Type    = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = var.glue_job_name
          Arguments = {
            "--RAW_BUCKET"       = var.raw_bucket_name
            "--PROCESSED_BUCKET" = var.processed_bucket_name
          }
        }
        Retry = [
          {
            ErrorEquals     = ["States.TaskFailed"]
            IntervalSeconds = 30
            MaxAttempts     = 2
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "JobFailed"
          }
        ]
        Next = "JobSucceeded"
      }

      # ── Step 2: Success state ────────────────────────────────────
      JobSucceeded = {
        Type = "Pass"
        Result = {
          status  = "SUCCESS"
          message = "ETL pipeline completed successfully"
        }
        End = true
      }

      # ── Step 3: Failure state ────────────────────────────────────
      JobFailed = {
        Type  = "Fail"
        Error = "ETLJobFailed"
        Cause = "The Glue ETL job failed. Check CloudWatch logs."
      }
    }
  })

  tags = {
    Project = var.project
  }
}
