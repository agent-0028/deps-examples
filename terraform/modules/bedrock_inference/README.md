# bedrock_inference

Terraform module for Bedrock inference profiles, IAM, and API keys. Tier maps live in `tiers.tf` (mantle model IDs for clients; separate provision IDs for IAM/profile resources).

## Unit tests

Tests live in `tests/` and use **mocked** AWS providers — no credentials, no remote state, and no connection to prod or nonprod.

From this directory:

```bash
tofu init   # once per clone; downloads the AWS provider locally only
tofu test
```

`init` here is not the same as `tofu init` under `terraform/nonprod` or `terraform/prod`. Those stacks configure the S3 backend and attach to environment state. This folder has no backend; `tofu test` never reads or writes state.

## Post-deploy smoke

After **Deploy Infra nonprod**, see `terraform/nonprod/test/e2e/README.md` for the OpenAI SDK mantle smoke test against real stack outputs.
