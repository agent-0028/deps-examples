module "example_dns_record" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/dns_record?ref=main"

  name       = "verify"
  type       = "TXT"
  records    = ["deps-examples-dns-record-example"]
  ttl        = 300
  zone_id    = module.example_hosted_zone.id
  env-suffix = module.config.env-suffix
  env        = module.config.env
}
