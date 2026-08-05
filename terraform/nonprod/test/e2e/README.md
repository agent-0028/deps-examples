# Bedrock inference e2e smoke

Post-deploy check: OpenAI SDK → Bedrock mantle Chat Completions, using `tofu output` from `terraform/nonprod`.

**Requires [Bun](https://bun.sh)** — install Bun on your machine first; this folder does not use npm/node.

## Setup (once)

```bash
cd terraform/nonprod/test/e2e
bun install
```

Also ensure `terraform/nonprod` has been initialized (`tofu init`) and **Deploy Infra nonprod** has applied the bedrock example.

## Run

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
