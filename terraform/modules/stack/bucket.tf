module "example_bucket" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/bucket?ref=main"
  attributes = {
    bucket : "deps-examples-bucket"
  }
  env-suffix = var.config.env_suffix
  env        = var.config.env
  repo       = var.config.repo
}
