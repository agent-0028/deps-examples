# Instructions for AI Coding Agents

This is a Terraform infrastructure project.

It is an "examples" repository for the [deps](https://github.com/agent-0028/deps) repository.

We are using OpenTofu, so the command line tool is `tofu`.

OpenTofu v1.11.1 is compatible with Terraform v1.5.7 and earlier versions.

Many examples online will use the official Terraform command line client,  `terraform`.

## Principles

The goal with this project is to utilize the GitHub Actions pipeline as much as possible.

Coding agents and humans should avoid running `tofu apply` or `tofu destroy` locally.

Instead, code should be merged and pushed to GitHub and run using GitHub Actions through the web console.

## Practices

You can run `tofu plan` locally to smoke test changes.

Pause and allow the user to review and commit changes when you are getting expected output from `tofu plan`.

Always run `tofu fmt` to auto-correct formatting.

## Environment lifecycle

This is an examples repo, not a long-lived staging environment. Treat the two environments differently:

**nonprod** — Ephemeral. Apply and destroy as needed to exercise examples. Do not assume resources persist between sessions. Use the **Deploy Infra nonprod** and **Destroy Infra nonprod** workflows for full cycles. It is fine (expected) for nonprod to have no resources most of the time.

**prod** — Maintained like production. Create resources and keep them through example code changes until cost or scope makes that impractical. Apply prod only from `main` after merge. The prod destroy workflow is intentionally stubbed; do not destroy prod casually.

Resource names are separated by `env-suffix` from the config module (nonprod gets `-nonprod`; prod gets none). Both environments may share one AWS account — naming is what keeps them apart.

## CI workflow

All workflows are manual (`workflow_dispatch`). When triggering from the GitHub Actions UI, select the branch to run from — checkout uses that branch, not always `main`.

- **Feature branches:** Run **Check Infra nonprod** or **Check Infra prod** (plan only). This is the preferred smoke test. Plan is read-only and does not modify remote state.
- **After merge to `main`:** Run **Deploy Infra** workflows to apply changes.
- **nonprod teardown:** Run **Destroy Infra nonprod** when done with a test cycle.

Avoid running **Deploy** or **Destroy** from feature branches — those write to the same remote state as `main`.

When developing against unreleased changes in deps, pin module and workflow refs to a deps branch temporarily. Revert those pins before merging to `main`.
