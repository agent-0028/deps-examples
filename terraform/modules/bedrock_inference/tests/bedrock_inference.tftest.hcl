mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_region" {
    defaults = {
      region = "us-west-2"
    }
  }
}

variables {
  env        = "nonprod"
  env-suffix = "-nonprod"
  repo       = "deps-examples"
}

run "anthropic_fast_tier_resolves_model_id" {
  command = plan

  variables {
    attributes = { tier = "fast", vendor = "anthropic" }
  }

  assert {
    condition     = output.model_id == "us.anthropic.claude-haiku-4-5-20251001-v1:0"
    error_message = "anthropic fast tier should resolve to the Haiku inference profile ID"
  }

  assert {
    condition     = output.tier == "fast"
    error_message = "tier output should echo the input tier"
  }

  assert {
    condition     = output.vendor == "anthropic"
    error_message = "vendor output should echo the input vendor"
  }
}

run "anthropic_balanced_tier_resolves_model_id" {
  command = plan

  variables {
    attributes = { tier = "balanced", vendor = "anthropic" }
  }

  assert {
    condition     = output.model_id == "us.anthropic.claude-sonnet-4-6"
    error_message = "anthropic balanced tier should resolve to the Sonnet inference profile ID"
  }
}

run "anthropic_capable_tier_resolves_model_id" {
  command = plan

  variables {
    attributes = { tier = "capable", vendor = "anthropic" }
  }

  assert {
    condition     = output.model_id == "us.anthropic.claude-opus-4-6-v1"
    error_message = "anthropic capable tier should resolve to the Opus inference profile ID"
  }
}

run "anthropic_default_vendor_when_omitted" {
  command = plan

  variables {
    attributes = { tier = "fast" }
  }

  assert {
    condition     = output.vendor == "anthropic"
    error_message = "vendor should default to anthropic when omitted"
  }
}

run "openai_fast_tier_resolves_model_id" {
  command = plan

  variables {
    attributes = { tier = "fast", vendor = "openai" }
  }

  assert {
    condition     = output.model_id == "openai.gpt-oss-20b-1:0"
    error_message = "openai fast tier should resolve to gpt-oss-20b"
  }

  assert {
    condition     = output.vendor == "openai"
    error_message = "vendor output should echo openai"
  }
}

run "openai_capable_tier_resolves_model_id" {
  command = plan

  variables {
    attributes = { tier = "capable", vendor = "openai" }
  }

  assert {
    condition     = output.model_id == "openai.gpt-oss-120b-1:0"
    error_message = "openai capable tier should resolve to gpt-oss-120b"
  }
}

run "indie_fast_tier_resolves_model_id" {
  command = plan

  variables {
    attributes = { tier = "fast", vendor = "indie" }
  }

  assert {
    condition     = output.model_id == "us.meta.llama3-2-11b-instruct-v1:0"
    error_message = "indie fast tier should resolve to Llama 3.2 11B"
  }

  assert {
    condition     = output.vendor == "indie"
    error_message = "vendor output should echo indie"
  }
}

run "indie_balanced_tier_resolves_model_id" {
  command = plan

  variables {
    attributes = { tier = "balanced", vendor = "indie" }
  }

  assert {
    condition     = output.model_id == "deepseek.v3.2"
    error_message = "indie balanced tier should resolve to DeepSeek V3.2"
  }
}

run "indie_capable_tier_resolves_model_id" {
  command = plan

  variables {
    attributes = { tier = "capable", vendor = "indie" }
  }

  assert {
    condition     = output.model_id == "us.deepseek.r1-v1:0"
    error_message = "indie capable tier should resolve to DeepSeek R1"
  }
}

run "explicit_model_id" {
  command = plan

  variables {
    attributes = { model_id = "us.anthropic.claude-sonnet-4-7" }
  }

  assert {
    condition     = output.model_id == "us.anthropic.claude-sonnet-4-7"
    error_message = "explicit model_id should pass through unchanged"
  }

  assert {
    condition     = output.tier == null
    error_message = "tier output should be null when model_id is used"
  }

  assert {
    condition     = output.vendor == null
    error_message = "vendor output should be null when model_id is used"
  }
}

run "explicit_foundation_model_id" {
  command = plan

  variables {
    attributes = { model_id = "deepseek.v3.2" }
  }

  assert {
    condition     = output.model_id == "deepseek.v3.2"
    error_message = "foundation model IDs should be accepted via model_id escape hatch"
  }
}

run "both_tier_and_model_id_fails_validation" {
  command = plan

  variables {
    attributes = {
      tier     = "fast"
      model_id = "us.anthropic.claude-sonnet-4-6"
    }
  }

  expect_failures = [
    var.attributes,
  ]
}

run "neither_tier_nor_model_id_fails_validation" {
  command = plan

  variables {
    attributes = {}
  }

  expect_failures = [
    var.attributes,
  ]
}

run "invalid_tier_fails_validation" {
  command = plan

  variables {
    attributes = { tier = "frontier" }
  }

  expect_failures = [
    var.attributes,
  ]
}

run "invalid_vendor_fails_validation" {
  command = plan

  variables {
    attributes = { tier = "fast", vendor = "mistral" }
  }

  expect_failures = [
    var.attributes,
  ]
}

run "invalid_model_id_fails_validation" {
  command = plan

  variables {
    attributes = { model_id = "NOT_A_VALID_MODEL" }
  }

  expect_failures = [
    var.attributes,
  ]
}

run "nonprod_tags_and_naming" {
  command = plan

  variables {
    attributes = { tier = "fast", vendor = "anthropic" }
  }

  assert {
    condition     = aws_iam_user.this[0].name == "bedrock-inference-nonprod"
    error_message = "IAM user name should include env-suffix"
  }

  assert {
    condition     = aws_iam_user.this[0].tags["Environment"] == "nonprod"
    error_message = "IAM user should be tagged with Environment"
  }

  assert {
    condition     = aws_bedrock_inference_profile.this[0].tags["Environment"] == "nonprod"
    error_message = "inference profile should be tagged with Environment"
  }
}

run "prod_tags_and_naming" {
  command = plan

  variables {
    attributes = { tier = "balanced", vendor = "anthropic" }
    env        = "prod"
    env-suffix = ""
  }

  assert {
    condition     = aws_iam_user.this[0].name == "bedrock-inference"
    error_message = "prod IAM user name should have no env-suffix"
  }

  assert {
    condition     = aws_iam_user.this[0].tags["Environment"] == "prod"
    error_message = "IAM user should be tagged with prod Environment"
  }
}

run "openai_base_url_contains_region" {
  command = plan

  variables {
    attributes = { tier = "fast", vendor = "anthropic" }
    aws_region = "eu-central-1"
  }

  assert {
    condition     = output.openai_base_url == "https://bedrock-runtime.eu-central-1.amazonaws.com/v1"
    error_message = "openai_base_url should use the configured region"
  }

  assert {
    condition     = output.openai_mantle_base_url == "https://bedrock-mantle.eu-central-1.api.aws/v1"
    error_message = "openai_mantle_base_url should use the configured region"
  }
}

run "indie_foundation_model_uses_foundation_model_arn" {
  command = plan

  variables {
    attributes = { tier = "balanced", vendor = "indie" }
  }

  assert {
    condition     = aws_bedrock_inference_profile.this[0].model_source[0].copy_from == "arn:aws:bedrock:us-west-2::foundation-model/deepseek.v3.2"
    error_message = "indie foundation model IDs should use a foundation-model ARN for model_source"
  }
}

run "anthropic_geo_profile_uses_inference_profile_arn" {
  command = plan

  variables {
    attributes = { tier = "fast", vendor = "anthropic" }
  }

  assert {
    condition     = aws_bedrock_inference_profile.this[0].model_source[0].copy_from == "arn:aws:bedrock:us-west-2:123456789012:inference-profile/us.anthropic.claude-haiku-4-5-20251001-v1:0"
    error_message = "geo inference profile IDs should use an inference-profile ARN for model_source"
  }
}

run "create_api_key_true_includes_iam_resources" {
  command = plan

  variables {
    attributes     = { tier = "fast", vendor = "anthropic" }
    create_api_key = true
  }

  assert {
    condition     = length(aws_iam_user.this) == 1
    error_message = "create_api_key true should plan an IAM user"
  }

  assert {
    condition     = length(aws_iam_service_specific_credential.this) == 1
    error_message = "create_api_key true should plan a Bedrock service credential"
  }
}

run "create_api_key_false_skips_iam_resources" {
  command = plan

  variables {
    attributes     = { tier = "fast", vendor = "anthropic" }
    create_api_key = false
  }

  assert {
    condition     = length(aws_iam_user.this) == 0
    error_message = "create_api_key false should not plan an IAM user"
  }

  assert {
    condition     = output.api_key == null
    error_message = "api_key output should be null when create_api_key is false"
  }
}
