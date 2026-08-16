variable "config" {
  type = object({
    aws_region = string
    env_prefix = string
    env_suffix = string
    env        = string
    is_prod    = bool
    repo       = string
  })
  description = "Environment configuration from the deps config module, passed in by the root module."
}

variable "example_object_content" {
  type        = string
  description = "Text file body uploaded by the object module example; typically differs per environment."
}
