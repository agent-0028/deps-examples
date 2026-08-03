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
# or: bun smoke.ts
```

Optional: `bun run typecheck`

The smoke test invokes `bedrock_inference_model_id` from stack outputs (mantle Chat Completions IDs). Override only for debugging: `BEDROCK_SMOKE_MODEL=openai.gpt-oss-20b bun run smoke`.

## List mantle model IDs

Query what your account/region exposes on the mantle `/v1/models` endpoint (same auth as smoke):

```bash
bun run list-mantle-models
```

Use those IDs when updating `terraform/modules/bedrock_inference/tiers.tf`. AWS documents the split between mantle and runtime IDs on each [model card](https://docs.aws.amazon.com/bedrock/latest/userguide/models-get-info.html).
