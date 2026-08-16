module "example_bedrock_inference" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/bedrock_inference?ref=main"

  attributes = { tier = "fast", vendor = "openai" }
  env-suffix = var.config.env_suffix
  env        = var.config.env
  repo       = var.config.repo
}
