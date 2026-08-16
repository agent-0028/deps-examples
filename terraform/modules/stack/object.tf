module "example_object" {
  source       = "git::https://github.com/agent-0028/deps.git//terraform/modules/object?ref=main"
  env-suffix   = var.config.env_suffix
  env          = var.config.env
  repo         = var.config.repo
  bucket       = module.example_bucket.current_bucket
  content_type = "text/plain"
  content      = var.example_object_content
  key          = "example-object.txt"
}
