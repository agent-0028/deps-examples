module "example_hosted_zone" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/hosted_zone?ref=add-env-suffix-to-dns-modules"

  name       = "deps-examples.example.com"
  env-suffix = module.config.env-suffix
  env        = module.config.env
  repo       = module.config.repo
}
