module "example_bucket" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/bucket?ref=main"
  attributes = {
    bucket : "deps-examples-bucket"
  }
  env-suffix = module.config.env-suffix
  env        = module.config.env
  repo       = module.config.repo
}