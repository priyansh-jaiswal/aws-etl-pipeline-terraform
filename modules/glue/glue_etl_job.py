"""
AWS Glue ETL Job - E-Commerce Sales Pipeline
Deployed via Terraform
"""

import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import functions as F
from pyspark.sql.types import DoubleType, IntegerType

# ── Initialize Glue context ───────────────────────────────────────
args        = getResolvedOptions(sys.argv, ['JOB_NAME', 'RAW_BUCKET', 'PROCESSED_BUCKET'])
sc          = SparkContext()
glueContext = GlueContext(sc)
spark       = glueContext.spark_session
job         = Job(glueContext)
job.init(args['JOB_NAME'], args)

RAW_BUCKET       = f"s3://{args['RAW_BUCKET']}/"
PROCESSED_BUCKET = f"s3://{args['PROCESSED_BUCKET']}/sales/"

# ── Step 1: Read raw CSV ──────────────────────────────────────────
print("Step 1: Reading raw CSV from S3...")
df = spark.read.option("header", "true") \
               .option("inferSchema", "true") \
               .csv(RAW_BUCKET)
print(f"  Rows loaded: {df.count()}")

# ── Step 2: Cast data types ───────────────────────────────────────
print("Step 2: Casting data types...")
df = df.withColumn("order_date",    F.to_date(F.col("order_date"),  "yyyy-MM-dd")) \
       .withColumn("ship_date",     F.to_date(F.col("ship_date"),   "yyyy-MM-dd")) \
       .withColumn("quantity",      F.col("quantity").cast(IntegerType())) \
       .withColumn("unit_price",    F.col("unit_price").cast(DoubleType())) \
       .withColumn("revenue",       F.col("revenue").cast(DoubleType())) \
       .withColumn("cost",          F.col("cost").cast(DoubleType())) \
       .withColumn("profit",        F.col("profit").cast(DoubleType())) \
       .withColumn("profit_margin", F.col("profit_margin").cast(DoubleType()))

# ── Step 3: Clean data ────────────────────────────────────────────
print("Step 3: Cleaning data...")
rows_before = df.count()
df = df.dropna(subset=["order_id", "order_date", "product_id", "revenue", "region"])
df = df.filter((F.col("revenue") > 0) & (F.col("quantity") > 0))
print(f"  Rows removed: {rows_before - df.count()}")

# ── Step 4: Derive new columns ────────────────────────────────────
print("Step 4: Adding derived columns...")
df = df.withColumn("order_year",     F.year(F.col("order_date"))) \
       .withColumn("order_month",    F.month(F.col("order_date"))) \
       .withColumn("order_quarter",  F.quarter(F.col("order_date"))) \
       .withColumn("days_to_ship",   F.datediff(F.col("ship_date"), F.col("order_date"))) \
       .withColumn("is_profitable",  F.when(F.col("profit") > 0, "Yes").otherwise("No")) \
       .withColumn("shipping_speed", F.when(F.col("days_to_ship") <= 2, "Fast")
                                      .when(F.col("days_to_ship") <= 5, "Standard")
                                      .otherwise("Slow"))

# ── Step 5: Split clean vs cancelled ─────────────────────────────
print("Step 5: Splitting clean and cancelled orders...")
df_clean     = df.filter(F.col("order_status") != "Cancelled")
df_cancelled = df.filter(F.col("order_status") == "Cancelled")

# ── Step 6: Write Parquet output ──────────────────────────────────
print("Step 6: Writing Parquet to S3...")
df_clean.write.mode("overwrite") \
    .partitionBy("region", "order_year") \
    .parquet(PROCESSED_BUCKET)

df_cancelled.write.mode("overwrite") \
    .parquet(PROCESSED_BUCKET.replace("/sales/", "/cancelled/"))

print("ETL job completed successfully!")
job.commit()
