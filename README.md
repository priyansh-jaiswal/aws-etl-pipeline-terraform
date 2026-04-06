# AWS Serverless ETL Pipeline with Terraform

## Architecture
CSV Upload → S3 → Lambda → Step Functions 
→ AWS Glue (PySpark) → S3 (Parquet) → Athena → QuickSight

## Tech Stack
Python | PySpark | SQL | Terraform | AWS S3 | AWS Glue
AWS Lambda | Step Functions | Amazon Athena | QuickSight | IAM

## Project Structure
terraform-etl-project/
├── main.tf
├── variables.tf
├── outputs.tf
└── modules/
    ├── s3/
    ├── iam/
    ├── glue/
    ├── lambda/
    └── stepfunctions/

## How to Deploy
# Clone the repo
git clone https://github.com/yourusername/aws-etl-pipeline-terraform

# Initialize Terraform
terraform init

# Preview resources
terraform plan

# Deploy everything
terraform apply

## How to Destroy
terraform destroy

## Pipeline Flow
1. Upload CSV to S3 raw bucket
2. S3 triggers Lambda automatically
3. Lambda starts Step Functions execution
4. Step Functions orchestrates Glue ETL job
5. Glue cleans and transforms data to Parquet
6. Processed data partitioned by region and year
7. Athena queries processed data via SQL
8. QuickSight dashboard shows business insights
