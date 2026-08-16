module "config" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/config?ref=main"
  env    = "nonprod"
  repo   = var.repo
}

module "stack" {
  source = "../modules/stack"

  config = {
    aws_region = module.config.aws_region
    env_prefix = module.config.env-prefix
    env_suffix = module.config.env-suffix
    env        = module.config.env
    is_prod    = module.config.is-prod
    repo       = module.config.repo
  }
  example_object_content = "deps-examples object module example — nonprod"
}

output "env-suffix" {
  value = module.stack.env-suffix
}

output "env" {
  value = module.stack.env
}

output "bedrock_inference_model_id" {
  value = module.stack.bedrock_inference_model_id
}

output "bedrock_inference_provision_model_id" {
  value = module.stack.bedrock_inference_provision_model_id
}

output "bedrock_inference_tier" {
  value = module.stack.bedrock_inference_tier
}

output "bedrock_inference_vendor" {
  value = module.stack.bedrock_inference_vendor
}

output "bedrock_inference_region" {
  value = module.stack.bedrock_inference_region
}

output "bedrock_inference_openai_base_url" {
  value = module.stack.bedrock_inference_openai_base_url
}

output "bedrock_inference_openai_mantle_base_url" {
  value = module.stack.bedrock_inference_openai_mantle_base_url
}

output "bedrock_inference_inference_profile_arn" {
  value = module.stack.bedrock_inference_inference_profile_arn
}

output "bedrock_inference_api_key" {
  value     = module.stack.bedrock_inference_api_key
  sensitive = true
}

output "bedrock_inference_pi_env" {
  value     = module.stack.bedrock_inference_pi_env
  sensitive = true
}

output "bedrock_inference_pi_command" {
  value = module.stack.bedrock_inference_pi_command
}
