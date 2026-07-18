#!/usr/bin/env bash
# Reference: https://github.com/norwoodj/helm-docs
set -eux

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Git Bash rewrites the container-side "/helm-docs" into a Windows path, which silently mounts the
# volume somewhere else. No effect on Linux or macOS.
export MSYS_NO_PATHCONV=1

echo -e "\n-- Running helm-docs --\n"
docker run \
    --rm \
    --volume "$REPO_ROOT:/helm-docs" \
    --user "$(id --user)" \
    jnorwood/helm-docs:v1.14.2 \
    --chart-search-root=charts \
    --skip-version-footer
