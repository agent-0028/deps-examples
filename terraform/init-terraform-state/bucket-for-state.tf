resource "aws_s3_bucket" "deps-example" {
  bucket              = "deps-example-bucket-for-state"
  bucket_prefix       = null
  force_destroy       = null
  object_lock_enabled = false
  tags = {
    repo = "deps-examples"
  }
}

resource "aws_s3_bucket_versioning" "deps-example" {
  bucket = aws_s3_bucket.deps-example.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "deps-example" {
  bucket = aws_s3_bucket.deps-example.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
