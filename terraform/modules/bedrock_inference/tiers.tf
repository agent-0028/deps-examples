# Vendor × tier → Bedrock model IDs for mantle Chat Completions (client) and provisioning (IAM/profile).
# Mantle IDs from AWS model cards: https://docs.aws.amazon.com/bedrock/latest/userguide/models-get-info.html
# Anthropic mantle models use the Messages API (/anthropic/v1/messages), not openai_mantle_base_url Chat Completions.
locals {
  tier_models = {
    anthropic = {
      fast = {
        mantle_model_id    = "anthropic.claude-haiku-4-5"
        provision_model_id = "us.anthropic.claude-haiku-4-5-20251001-v1:0"
      }
      balanced = {
        mantle_model_id    = "anthropic.claude-sonnet-5"
        provision_model_id = "us.anthropic.claude-sonnet-5"
      }
      capable = {
        mantle_model_id    = "anthropic.claude-opus-4-7"
        provision_model_id = "us.anthropic.claude-opus-4-7"
      }
    }
    openai = {
      fast = {
        mantle_model_id    = "openai.gpt-oss-20b"
        provision_model_id = "openai.gpt-oss-20b-1:0"
      }
      balanced = {
        mantle_model_id    = "openai.gpt-oss-120b"
        provision_model_id = "openai.gpt-oss-120b-1:0"
      }
      capable = {
        mantle_model_id    = "openai.gpt-oss-120b"
        provision_model_id = "openai.gpt-oss-120b-1:0"
      }
    }
    indie = {
      fast = {
        mantle_model_id    = "google.gemma-3-4b-it"
        provision_model_id = "google.gemma-3-4b-it"
      }
      balanced = {
        mantle_model_id    = "deepseek.v3.2"
        provision_model_id = "deepseek.v3.2"
      }
      capable = {
        mantle_model_id    = "qwen.qwen3-235b-a22b-2507"
        provision_model_id = "qwen.qwen3-235b-a22b-2507-v1:0"
      }
    }
  }
}
