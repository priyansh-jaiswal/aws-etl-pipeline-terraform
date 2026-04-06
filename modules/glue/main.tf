# ── Upload Glue script to S3 ─────────────────────────────────────
resource "aws_s3_object" "glue_script" {
  bucket = var.script_bucket_name
  key    = "scripts/glue_etl_job.py"
  source = "${path.module}/glue_etl_job.py"
  etag   = filemd5("${path.module}/glue_etl_job.py")
}

# ── Glue ETL Job ─────────────────────────────────────────────────
resource "aws_glue_job" "etl_job" {
  name         = "${var.project}-etl-job"
  role_arn     = var.glue_role_arn
  glue_version = "4.0"
  max_retries  = 1

  command {
    name            = "glueetl"
    script_location = "s3://${var.script_bucket_name}/scripts/glue_etl_job.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--RAW_BUCKET"                       = var.raw_bucket_name
    "--PROCESSED_BUCKET"                 = var.proc_bucket_name
  }

  worker_type       = "G.1X"
  number_of_workers = 2

  tags = {
    Project = var.project
  }
}

# ── Glue Database ─────────────────────────────────────────────────
resource "aws_glue_catalog_database" "ecommerce_db" {
  name = "${replace(var.project, "-", "_")}_db"
}

# ── Glue Crawler ─────────────────────────────────────────────────
resource "aws_glue_crawler" "sales_crawler" {
  name          = "${var.project}-crawler"
  role          = var.glue_role_arn
  database_name = aws_glue_catalog_database.ecommerce_db.name

  s3_target {
    path = "s3://${var.proc_bucket_name}/sales/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  tags = {
    Project = var.project
  }
}
