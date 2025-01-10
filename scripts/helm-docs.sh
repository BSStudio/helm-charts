#!/usr/bin/env bash
# Reference: https://github.com/norwoodj/helm-docs
set -eux

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Running Helm-Docs"
docker run \
    --rm \
    -v "$REPO_ROOT:/helm-docs" \
    -u $(id -u) \
    jnorwood/helm-docs:v1.14.2
