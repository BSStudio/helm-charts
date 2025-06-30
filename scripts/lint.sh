#!/usr/bin/env bash
# Reference: https://github.com/helm/chart-testing
set -eux

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "\n-- Linting all Helm Charts --\n"
docker run \
    --rm \
    --workdir="//data" \
    --volume "/${REPO_ROOT}:/data" \
    --entrypoint //bin/sh \
    quay.io/helmpack/chart-testing:v3.13.0 \
    -c "
        git config --global --add safe.directory /data && \
        ct lint \
            --debug \
            --config .github/configs/ct.yaml \
            --lint-conf .github/configs/.yaml-lint.yml
    "
# Update lint-test.yaml workflow when updating image version.
