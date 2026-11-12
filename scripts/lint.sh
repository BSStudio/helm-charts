#!/usr/bin/env bash
# Reference: https://github.com/helm/chart-testing
set -eux

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "\n-- Linting all Helm Charts --\n"
# Chart.lock is gitignored, so a local one goes stale when a dependency is bumped and ct's dependency build rejects it.
docker run \
    --rm \
    --workdir="//data" \
    --volume "/${REPO_ROOT}:/data" \
    --entrypoint //bin/sh \
    quay.io/helmpack/chart-testing:v3.15.0 \
    -c "
        git config --global --add safe.directory /data && \
        rm -f charts/*/Chart.lock && \
        ct lint \
            --debug \
            --config .github/configs/ct.yaml \
            --lint-conf .github/configs/.yaml-lint.yml
    "
# Update lint-test.yml workflow when updating image version.
