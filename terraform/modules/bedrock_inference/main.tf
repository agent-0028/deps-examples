terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.53.0"
    }
  }
}

variable "attributes" {
  type = object({
    tier     = optional(string)
    model_id = optional(string)
    vendor   = optional(string, "anthropic")
  })

  validation {
    condition     = (var.attributes.tier != null) != (var.attributes.model_id != null)
    error_message = "Set exactly one of attributes.tier or attributes.model_id."
  }

  validation {
    condition = (
      var.attributes.tier == null ||
      contains(["fast", "balanced", "capable"], var.attributes.tier)
    )
    error_message = "attributes.tier must be fast, balanced, or capable."
  }

  validation {
    condition     = contains(["anthropic", "openai", "indie"], var.attributes.vendor)
    error_message = "attributes.vendor must be anthropic, openai, or indie."
  }

  validation {
    condition = (
      var.attributes.model_id == null ||
      can(regex("^(us|eu|global|jp|au|us-gov)\\.", var.attributes.model_id)) ||
      can(regex("^[a-z0-9][a-z0-9.-]+(:[0-9]+)?$", var.attributes.model_id))
    )
    error_message = "attributes.model_id must be a Bedrock inference profile ID or foundation model ID."
  }
}

variable "env" {
  type = string
}

variable "env-suffix" {
  type = string
}

variable "repo" {
  type = string
}

variable "aws_region" {
  type    = string
  default = null
}

variable "create_api_key" {
  type    = bool
  default = true
}

variable "create_application_profile" {
  type    = bool
  default = true
}

variable "api_key_age_days" {
  type    = number
  default = null
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  region                 = coalesce(var.aws_region, data.aws_region.current.region)
  resolved_model_id      = var.attributes.model_id != null ? var.attributes.model_id : local.tier_models[var.attributes.vendor][var.attributes.tier]
  uses_geo_profile       = can(regex("^(us|eu|global|jp|au|us-gov)\\.", local.resolved_model_id))
  model_source_arn       = local.uses_geo_profile ? "arn:aws:bedrock:${local.region}:${data.aws_caller_identity.current.account_id}:inference-profile/${local.resolved_model_id}" : "arn:aws:bedrock:${local.region}::foundation-model/${local.resolved_model_id}"
  openai_base_url        = "https://bedrock-runtime.${local.region}.amazonaws.com/v1"
  openai_mantle_base_url = "https://bedrock-mantle.${local.region}.api.aws/v1"
  iam_user_name          = "bedrock-inference${var.env-suffix}"
  inference_profile_name = "bedrock-inference${var.env-suffix}"
}
