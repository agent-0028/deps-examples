# bedrock_inference

Terraform module for Bedrock inference profiles, IAM, and API keys. Tier maps live in `tiers.tf`.

## Model IDs: mantle vs provision

Bedrock uses **different model ID strings** depending on how you call it. Each vendor×tier cell in `tiers.tf` stores both:

| Field in `tiers.tf` | Output | Used for |
|---------------------|--------|----------|
| `mantle_model_id` | `model_id` | OpenAI SDK Chat Completions on `openai_mantle_base_url` |
| `provision_model_id` | `provision_model_id` (via `pi_command`) | IAM invoke scope, application inference profile, Pi native Bedrock provider |

When they differ (e.g. mantle `openai.gpt-oss-20b` vs runtime `openai.gpt-oss-20b-1:0`), pass **`model_id`** to OpenAI-compatible clients and **`provision_model_id`** (or `pi_command`) to Pi / runtime paths.

Explicit `attributes.model_id` sets both outputs to the same value (escape hatch).

## Vendor × endpoint

Amazon hosts the HTTP endpoints; this module does not. Pick the base URL and model output for your client:

| Vendor | Primary client path | Base URL output | Model output |
|--------|---------------------|-----------------|--------------|
| `openai` | Mantle Chat Completions (OpenAI SDK) | `openai_mantle_base_url` | `model_id` |
| `indie` | Mantle Chat Completions (OpenAI SDK) | `openai_mantle_base_url` | `model_id` |
| `anthropic` | Pi / runtime (Messages or Converse) | `openai_base_url` or Anthropic Messages on mantle | `provision_model_id` for Pi; `model_id` is the mantle Messages ID |

Anthropic on mantle uses the **Messages API** (`/anthropic/v1/messages`), not `openai_mantle_base_url` Chat Completions. Prefer **`openai` or `indie`** for OpenAI SDK smoke tests.

## Unit tests

Tests live in `tests/` and use **mocked** AWS providers — no credentials, no remote state, and no connection to prod or nonprod.

From this directory:

```bash
tofu init   # once per clone; downloads the AWS provider locally only
tofu test
```

`init` here is not the same as `tofu init` under `terraform/nonprod` or `terraform/prod`. Those stacks configure the S3 backend and attach to environment state. This folder has no backend; `tofu test` never reads or writes state.

## Post-deploy smoke

After **Deploy Infra nonprod**, see `terraform/nonprod/test/e2e/README.md` for the OpenAI SDK mantle smoke test against real stack outputs. The nonprod example uses `vendor = "openai"` so `model_id` matches the smoke client path.
