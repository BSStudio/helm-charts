#!/usr/bin/env bash
# Reference: https://github.com/norwoodj/helm-docs
set -eux

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "\n-- Running helm-docs --\n"
docker run \
    --rm \
    --volume "$REPO_ROOT:/helm-docs" \
    --user "$(id --user)" \
    jnorwood/helm-docs:v1.14.2 \
    --skip-version-footer
