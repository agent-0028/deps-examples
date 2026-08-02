resource "aws_bedrock_inference_profile" "this" {
  count = var.create_application_profile ? 1 : 0

  name        = local.inference_profile_name
  description = "Application inference profile for ${local.provision_model_id}"

  model_source {
    copy_from = local.model_source_arn
  }

  tags = {
    Repo        = var.repo
    Environment = var.env
  }
}

resource "aws_iam_user" "this" {
  count = var.create_api_key ? 1 : 0

  name = local.iam_user_name

  tags = {
    Repo        = var.repo
    Environment = var.env
  }
}

resource "aws_iam_user_policy" "invoke" {
  count = var.create_api_key ? 1 : 0

  name = "bedrock-invoke"
  user = aws_iam_user.this[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
        ]
        Resource = compact([
          var.create_application_profile ? aws_bedrock_inference_profile.this[0].arn : null,
          local.model_source_arn,
        ])
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock-mantle:CreateInference",
          "bedrock-mantle:CallWithBearerToken",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_service_specific_credential" "this" {
  count = var.create_api_key ? 1 : 0

  service_name        = "bedrock.amazonaws.com"
  user_name           = aws_iam_user.this[0].name
  credential_age_days = var.api_key_age_days
}

output "model_id" {
  value = local.resolved_model_id
}

output "provision_model_id" {
  value = local.provision_model_id
}

output "tier" {
  value = var.attributes.tier
}

output "vendor" {
  value = var.attributes.model_id != null ? null : var.attributes.vendor
}

output "openai_base_url" {
  value = local.openai_base_url
}

output "openai_mantle_base_url" {
  value = local.openai_mantle_base_url
}

output "region" {
  value = local.region
}

output "inference_profile_arn" {
  value = var.create_application_profile ? aws_bedrock_inference_profile.this[0].arn : local.model_source_arn
}

output "api_key" {
  value     = var.create_api_key ? aws_iam_service_specific_credential.this[0].service_credential_secret : null
  sensitive = true
}

output "iam_user_name" {
  value = var.create_api_key ? aws_iam_user.this[0].name : null
}

output "pi_env" {
  value     = var.create_api_key ? "export AWS_BEARER_TOKEN_BEDROCK=${aws_iam_service_specific_credential.this[0].service_credential_secret}\nexport AWS_REGION=${local.region}" : null
  sensitive = true
}

output "pi_command" {
  value = "pi --provider amazon-bedrock --model ${local.provision_model_id}"
}
