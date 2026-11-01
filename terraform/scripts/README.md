# Bedrock inference scripts

Post-deploy helpers for the Bedrock example stack. Default stack is **nonprod**; pass `--env prod` or set `DEPS_STACK=prod` for prod.

**Requires [Bun](https://bun.sh)** — install Bun on your machine first; this folder does not use npm/node.

## Credential conventions

Scripts fall into two groups. The prefix tells you **which IAM principal** acts on AWS.

| Prefix | Scripts | Credentials | IAM principal |
|--------|---------|-------------|---------------|
| *(none)* | `smoke`, `pi-config` | `tofu output bedrock_inference_api_key` (Bedrock bearer token) | `bedrock-inference{env-suffix}` — the narrow user Terraform created |
| `admin-` | `admin-list-mantle-models` | Shell AWS default chain (`AWS_PROFILE`, `AWS_ACCESS_KEY_ID`, …) | Whatever your local/admin profile resolves to (logged via STS) |

**Stack scripts** prove the deployed inference user can do its job (invoke the configured model). They do **not** use your shell `AWS_*` variables for Bedrock HTTP calls.

**Admin scripts** use SigV4 with your shell credentials for maintainer tasks (listing models, etc.) that need broader IAM than the inference user. Set `AWS_PROFILE` when you are not using the default profile:

```bash
AWS_PROFILE=admin bun run admin-list-mantle-models
```

Each script logs the acting principal on stderr before doing work, for example:

```
auth=stack-api-key stack=nonprod iam_user=bedrock-inference-nonprod
auth=local-aws profile=admin region=us-west-2 principal=arn:aws:iam::123456789012:user/you
```

`--env` / `DEPS_STACK` on admin scripts only selects which stack to read for **region** when `AWS_REGION` is unset — not which API key to use.

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
AWS_PROFILE=admin bun run admin-list-mantle-models -- --env prod
```

## Smoke test

```bash
bun run smoke
```

Optional: `bun run typecheck`

`smoke` invokes `bedrock_inference_model_id` from stack outputs — the model configured in the stack module.

Optional: override the model to probe IAM authorization (expect failure when the model differs from what Terraform provisioned):

```bash
BEDROCK_SMOKE_MODEL=google.gemma-3-4b-it bun run smoke
```

## List mantle model IDs (admin)

```bash
AWS_PROFILE=admin bun run admin-list-mantle-models
```

Requires IAM permission `bedrock-mantle:ListModels` on your **local** principal — not the stack inference user.

Use those IDs when updating `tiers.tf` in deps. AWS documents mantle vs runtime IDs on each [model card](https://docs.aws.amazon.com/bedrock/latest/userguide/models-get-info.html).

## Pi coding agent

Pi uses the **Converse / runtime** path (`provision_model_id`), not mantle Chat Completions. Stack outputs include `bedrock_inference_pi_env` and `bedrock_inference_pi_command`; this script formats them for copy-paste:

```bash
bun run pi-config
```

Add `--show-secrets` to include the bearer token in the shell exports and `auth.json` block.
