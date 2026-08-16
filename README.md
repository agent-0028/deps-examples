# deps-examples

OpenTofu examples for the [deps](https://github.com/agent-0028/deps) module library.

## Layout

Infrastructure is split so prod and nonprod run the **same** stack code with different configuration:

```
terraform/
  modules/stack/     # shared implementation — all example resources live here
  prod/              # prod root module (separate remote state)
  nonprod/           # nonprod root module (separate remote state)
```

Each environment root module has three files:

| File | Role |
|---|---|
| `main.tf` | Provider, remote backend, and other global bootstrap |
| `variables.tf` | Input variables for this environment |
| `stack.tf` | Invokes `../modules/stack` with environment-specific values |

**prod** and **nonprod** differ only in what they pass to config and the stack — notably `env`, the backend state key, and values like `example_object_content`. Each environment calls the deps [config module](https://github.com/agent-0028/deps/tree/main/terraform/modules/config) in `stack.tf`, builds a `config` object from its outputs, and passes that into the shared stack module.

State is fully separated: each environment has its own S3 backend key under `terraform/prod/main.tf` and `terraform/nonprod/main.tf`.

## Repo and pipeline set up

* Change `terraform/nonprod/main.tf`:
    * change the bucket for state to one you own instead of `deps-examples-bucket-for-state`
    * specify a new key for state instead of `terraform-state/deps-examples-nonprod/tf`
* Change `terraform/prod/main.tf`:
    * change the bucket for state to one you own instead of `deps-examples-bucket-for-state`
    * specify a new key for state instead of `terraform-state/deps-examples-prod/tf`
* Create two GitHub Actions environments:
    * `prod`
    * `nonprod`
* Populate these secrets in both GitHub Action environments
    * `AWS_SECRET_ACCESS_KEY`
* Populate these environment variables in both GitHub Action environments
    * `AWS_ACCESS_KEY_ID`
    * `AWS_DEFAULT_REGION`

## Setup for local dev

The goal is to use local commands to verify a plan, and then use the GitHub Actions pipeline to actually apply it to create your infrastructure.

* Install [OpenTofu](https://opentofu.org) for your operating system.
* Initialize the backend for local dev:
    * `tofu init`

## Local Dev Cheat Sheet

### Non-prod

```
cd terraform/nonprod
tofu workspace select --or-create dev
tofu plan
```

### Prod

```
cd terraform/prod
tofu workspace select default
tofu plan
```

Format all Terraform in the tree from the repo root:

```
cd terraform
tofu fmt -recursive
```
