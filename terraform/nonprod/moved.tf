# Refactor: example resources moved into the local stack module (same AWS resources).
moved {
  from = module.example_bucket
  to   = module.stack.module.example_bucket
}

moved {
  from = module.example_object
  to   = module.stack.module.example_object
}

moved {
  from = module.example_hosted_zone
  to   = module.stack.module.example_hosted_zone
}

moved {
  from = module.example_dns_record
  to   = module.stack.module.example_dns_record
}

moved {
  from = module.example_dns_alias
  to   = module.stack.module.example_dns_alias
}

moved {
  from = module.example_bedrock_inference
  to   = module.stack.module.example_bedrock_inference
}

moved {
  from = aws_s3_bucket.dns_alias_target
  to   = module.stack.aws_s3_bucket.dns_alias_target
}

moved {
  from = aws_s3_bucket_website_configuration.dns_alias_target
  to   = module.stack.aws_s3_bucket_website_configuration.dns_alias_target
}

moved {
  from = aws_s3_bucket_public_access_block.dns_alias_target
  to   = module.stack.aws_s3_bucket_public_access_block.dns_alias_target
}

moved {
  from = aws_s3_bucket_policy.dns_alias_target
  to   = module.stack.aws_s3_bucket_policy.dns_alias_target
}
