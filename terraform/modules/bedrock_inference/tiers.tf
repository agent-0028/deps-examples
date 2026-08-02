# Vendor × tier → Bedrock model or inference profile ID.
# Update this map as you learn what works in your account/region; tests pin current values.
locals {
  tier_models = {
    anthropic = {
      fast     = "us.anthropic.claude-haiku-4-5-20251001-v1:0"
      balanced = "us.anthropic.claude-sonnet-4-6"
      capable  = "us.anthropic.claude-opus-4-6-v1"
    }
    openai = {
      fast     = "openai.gpt-oss-20b-1:0"
      balanced = "openai.gpt-oss-120b-1:0"
      capable  = "openai.gpt-oss-120b-1:0"
    }
    indie = {
      fast     = "meta.llama3-1-8b-instruct-v1:0" # ON_DEMAND + INFERENCE_PROFILE in us-west-2
      balanced = "deepseek.v3.2"                  # ON_DEMAND
      capable  = "us.deepseek.r1-v1:0"            # INFERENCE_PROFILE (geo ID for deepseek.r1-v1:0)
    }
  }
}
