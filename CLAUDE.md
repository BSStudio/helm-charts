# CLAUDE.md

Helm charts for Budavári Schönherz Stúdió's applications, published at `https://charts.bsstudio.hu`.

Read [CONVENTIONS.md](CONVENTIONS.md) before creating or changing a chart. It is the authority on chart structure, values naming, and the rules that are easy to get wrong. `charts/outline` and `charts/request-manager` are the reference implementations.

## Before calling something done

```bash
pre-commit run --all-files   # includes helm lint, ct lint through scripts/lint.sh, and helm-docs
```

To rerun one part on its own: `scripts/lint.sh` runs `ct lint` on the charts changed against `origin/main`, as CI does; `scripts/helm-docs.sh` regenerates the chart READMEs. pre-commit and both scripts need Docker. The chart-testing hook can't run from a git worktree, so run the checks from the main clone.

`helm template` and `helm lint` do not prove the app starts. Say so when reporting results, and treat the `ct install` run on the PR as the first real test.

## Commits and branches

Commit messages and PR titles are plain imperative sentences. PRs are squash-merged: the PR title becomes the commit on `main`, with an empty body.

## Rules

- Bump the chart's `version` in `Chart.yaml` on every chart change; each new version is released as its own chart release.
- Verify before asserting. Whether a health endpoint touches the database, what an app's shutdown timeout is, which settings it reads with no default — read the upstream source rather than assuming. These decide chart behaviour, and a wrong guess sends the work in the wrong direction.
