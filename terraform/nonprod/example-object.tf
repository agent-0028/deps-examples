module "example_object" {
  source       = "git::https://github.com/agent-0028/deps.git//terraform/modules/object?ref=main"
  env-suffix   = module.config.env-suffix
  env          = module.config.env
  repo         = module.config.repo
  bucket       = module.example_bucket.current_bucket
  content_type = "text/plain"
  content      = "deps-examples object module example"
  key          = "example-object.txt"
}
