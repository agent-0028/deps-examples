# Bedrock inference scripts

Post-deploy helpers that read OpenTofu stack outputs. Default stack is **nonprod**; pass `--env prod` or set `DEPS_STACK=prod` for prod.

**Requires [Bun](https://bun.sh)** — install Bun on your machine first; this folder does not use npm/node.

## Setup (once)

```bash
cd terraform/scripts
bun install
```

Ensure the target stack has been initialized (`tofu init` in `terraform/nonprod` or `terraform/prod`) and **Deploy Infra** has applied the bedrock example.

## Stack selection

Default: `nonprod` (`terraform/nonprod`).

```bash
bun run smoke -- --env prod
DEPS_STACK=prod bun run pi-config
```

## Smoke test

```bash
bun run smoke
```

Optional: `bun run typecheck`

`smoke` invokes `bedrock_inference_model_id` from stack outputs — the model configured in `example-bedrock-inference.tf`.

Optional: override the model to probe IAM authorization (expect failure when the model differs from what Terraform provisioned):

```bash
BEDROCK_SMOKE_MODEL=google.gemma-3-4b-it bun run smoke
```

## List mantle model IDs

```bash
bun run list-mantle-models
```

Use those IDs when updating `tiers.tf` in deps. AWS documents mantle vs runtime IDs on each [model card](https://docs.aws.amazon.com/bedrock/latest/userguide/models-get-info.html).

## Pi coding agent

Pi uses the **Converse / runtime** path (`provision_model_id`), not mantle Chat Completions. Stack outputs include `bedrock_inference_pi_env` and `bedrock_inference_pi_command`; this script formats them for copy-paste:

```bash
bun run pi-config
```

Add `--show-secrets` to include the bearer token in the shell exports and `auth.json` block.
