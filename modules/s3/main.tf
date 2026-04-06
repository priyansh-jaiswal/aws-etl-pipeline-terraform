# ── Raw Bucket ───────────────────────────────────────────────────
resource "aws_s3_bucket" "raw" {
  bucket        = "${var.project}-raw-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "${var.project}-raw"
    Environment = var.environment
    Project     = var.project
  }
}

# ── Processed Bucket ─────────────────────────────────────────────
resource "aws_s3_bucket" "processed" {
  bucket        = "${var.project}-processed-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "${var.project}-processed"
    Environment = var.environment
    Project     = var.project
  }
}

# ── Random suffix to ensure unique bucket names ──────────────────
resource "random_id" "suffix" {
  byte_length = 4
}

# ── Block all public access on both buckets ──────────────────────
resource "aws_s3_bucket_public_access_block" "raw" {
  bucket                  = aws_s3_bucket.raw.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "processed" {
  bucket                  = aws_s3_bucket.processed.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── Versioning on raw bucket ─────────────────────────────────────
resource "aws_s3_bucket_versioning" "raw" {
  bucket = aws_s3_bucket.raw.id
  versioning_configuration {
    status = "Enabled"
  }
}
