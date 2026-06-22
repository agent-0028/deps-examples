# template-tofu
A template repo for OpenTofu projects.

## Repo and pipeline set up

* Change `nonprod/main.tf`:
    * change the bucket for state to one you own instead of `example-bucket-for-state`
    * specify a new key for state instead of `terraform-state/template-tofu-nonprod/tf"`
* Change `prod/main.tf`:
    * change the bucket for state to one you own instead of `example-bucket-for-state`
    * specify a new key for state instead of `terraform-state/template-tofu-prod/tf`
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
```

### Prod

```
cd terraform/prod
tofu workspace select default
```

## All environments

```
tofu plan
tofu apply
tofo destroy
```