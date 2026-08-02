module "example_bedrock_inference" {
  source = "../modules/bedrock_inference"

  attributes = { tier = "fast", vendor = "openai" }
  env-suffix = module.config.env-suffix
  env        = module.config.env
  repo       = module.config.repo
}

output "bedrock_inference_model_id" {
  value = module.example_bedrock_inference.model_id
}

output "bedrock_inference_tier" {
  value = module.example_bedrock_inference.tier
}

output "bedrock_inference_vendor" {
  value = module.example_bedrock_inference.vendor
}

output "bedrock_inference_region" {
  value = module.example_bedrock_inference.region
}

output "bedrock_inference_openai_base_url" {
  value = module.example_bedrock_inference.openai_base_url
}

output "bedrock_inference_openai_mantle_base_url" {
  value = module.example_bedrock_inference.openai_mantle_base_url
}

output "bedrock_inference_inference_profile_arn" {
  value = module.example_bedrock_inference.inference_profile_arn
}

output "bedrock_inference_api_key" {
  value     = module.example_bedrock_inference.api_key
  sensitive = true
}

output "bedrock_inference_pi_env" {
  value     = module.example_bedrock_inference.pi_env
  sensitive = true
}

output "bedrock_inference_pi_command" {
  value = module.example_bedrock_inference.pi_command
}
