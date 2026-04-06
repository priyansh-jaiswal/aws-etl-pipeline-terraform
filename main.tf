terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# ── S3 Module ────────────────────────────────────────────────────
module "s3" {
  source      = "./modules/s3"
  project     = var.project
  environment = var.environment
}

# ── IAM Module ───────────────────────────────────────────────────
module "iam" {
  source          = "./modules/iam"
  project         = var.project
  raw_bucket_arn  = module.s3.raw_bucket_arn
  proc_bucket_arn = module.s3.processed_bucket_arn
}

# ── Glue Module ──────────────────────────────────────────────────
module "glue" {
  source             = "./modules/glue"
  project            = var.project
  glue_role_arn      = module.iam.glue_role_arn
  raw_bucket_name    = module.s3.raw_bucket_name
  proc_bucket_name   = module.s3.processed_bucket_name
  script_bucket_name = module.s3.raw_bucket_name
}

# ── Step Functions Module ────────────────────────────────────────
module "stepfunctions" {
  source                = "./modules/stepfunctions"
  project               = var.project
  sfn_role_arn          = module.iam.sfn_role_arn
  glue_job_name         = module.glue.glue_job_name
  raw_bucket_name       = module.s3.raw_bucket_name
  processed_bucket_name = module.s3.processed_bucket_name
}

# ── Lambda Module ────────────────────────────────────────────────
module "lambda" {
  source           = "./modules/lambda"
  project          = var.project
  lambda_role_arn  = module.iam.lambda_role_arn
  glue_job_name    = module.glue.glue_job_name
  raw_bucket_name  = module.s3.raw_bucket_name
  raw_bucket_arn   = module.s3.raw_bucket_arn
  sfn_arn          = module.stepfunctions.state_machine_arn
}
