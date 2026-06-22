resource "aws_s3_bucket" "tofu-template-example" {
  bucket              = "example-bucket-for-state"
  bucket_prefix       = null
  force_destroy       = null
  object_lock_enabled = false
  tags = {
    some-tag = "example"
  }
}

resource "aws_s3_bucket_versioning" "tofu-template-example" {
  bucket = aws_s3_bucket.tofu-template-example.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tofu-template-example" {
  bucket = aws_s3_bucket.tofu-template-example.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
