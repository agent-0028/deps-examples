module "example_hosted_zone" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/hosted_zone?ref=main"

  # Subdomain zone under sproutlandscapedesign.com (managed in tinisi/infra); example.com is reserved by AWS
  name       = "deps-examples.sproutlandscapedesign.com"
  env-suffix = var.config.env_suffix
  env        = var.config.env
  repo       = var.config.repo
}
