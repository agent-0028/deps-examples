provider "aws" {
  region = module.config.aws_region
}

terraform {
  backend "s3" {
    bucket = "example-bucket-for-state"
    # Change this!
    # Should be different from prod.
    key    = "terraform-state/template-tofu-nonprod/tf"
    region = "us-west-2"
  }
}

module "config" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/config?ref=main"
  env    = "nonprod"
  repo   = var.repo
}
output "env-suffix" {
  value = module.config.env-suffix
}

output "env" {
  value = module.config.env
}
