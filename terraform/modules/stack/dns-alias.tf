locals {
  # S3 website aliases require the bucket name to match the Route53 record FQDN
  www_fqdn = "www.${module.example_hosted_zone.qualified_name}"
}

resource "aws_s3_bucket" "dns_alias_target" {
  bucket = local.www_fqdn

  tags = {
    Repo        = var.config.repo
    Environment = var.config.env
  }
}

resource "aws_s3_bucket_website_configuration" "dns_alias_target" {
  bucket = aws_s3_bucket.dns_alias_target.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "dns_alias_target" {
  bucket = aws_s3_bucket.dns_alias_target.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "dns_alias_target" {
  bucket = aws_s3_bucket.dns_alias_target.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.dns_alias_target.arn}/*"
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.dns_alias_target]
}

module "example_dns_alias" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/dns_alias?ref=main"

  name                   = "www"
  zone_id                = module.example_hosted_zone.id
  value                  = aws_s3_bucket_website_configuration.dns_alias_target.website_endpoint
  alias_zone_id          = "Z3BJ6K6RIION7M" # S3 website hosted zone ID for us-west-2
  evaluate_target_health = false
  env-suffix             = var.config.env_suffix
  env                    = var.config.env
}
