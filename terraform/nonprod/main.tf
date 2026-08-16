provider "aws" {
  region = module.config.aws_region
}

terraform {
  backend "s3" {
    bucket = "deps-examples-bucket-for-state"
    # Change this!
    # Should be different from prod.
    key    = "terraform-state/deps-examples-nonprod/tf"
    region = "us-west-2"
  }
}
