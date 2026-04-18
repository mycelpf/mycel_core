#!/bin/bash
# mycel_core/mycel_core_infra/dockerfile/scripts/build-core-web.sh
#
# Builds and tags mycel_core_web's two published images:
#   1. mycel_core_web:${VERSION}          — Next.js standalone runtime
#   2. mycel_core_web-builder:${VERSION}  — full builder (source + next CLI + deps)
#
# Downstream module Dockerfile.web files inherit from the -builder image via
# `FROM ghcr.io/mycelpf/mycel_core_web-builder:${CORE_VERSION}` — so this
# script tags each image with BOTH its local short name and its ghcr path so
# local module builds resolve without needing to hit ghcr.
#
# Usage:
#   build-core-web.sh <version> [--push]
#     --push   — also push both tags to ghcr.io/mycelpf (requires prior docker login)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CORE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"       # mycel_core/
WORKSPACE="$(cd "$CORE_DIR/.." && pwd)"              # active_workspace/
DOCKERFILE="$CORE_DIR/mycel_core_infra/dockerfile/Dockerfile.core-web"

VERSION="${1:?Usage: build-core-web.sh <version> [--push]}"
PUSH="${2:-}"

REGISTRY="ghcr.io/mycelpf"
RUNTIME_LOCAL="mycel_core_web:${VERSION}"
RUNTIME_REMOTE="${REGISTRY}/mycel_core_web:${VERSION}"
BUILDER_LOCAL="mycel_core_web-builder:${VERSION}"
BUILDER_REMOTE="${REGISTRY}/mycel_core_web-builder:${VERSION}"

cd "$CORE_DIR"

echo "=== Building builder stage ==="
docker build \
  --target builder \
  -t "$BUILDER_LOCAL" \
  -t "$BUILDER_REMOTE" \
  -f "$DOCKERFILE" \
  .

echo "=== Building runtime stage ==="
docker build \
  --target runtime \
  -t "$RUNTIME_LOCAL" \
  -t "$RUNTIME_REMOTE" \
  -f "$DOCKERFILE" \
  .

# Also tag both as :latest so local dev / "CORE_VERSION=latest" build-args resolve
docker tag "$BUILDER_LOCAL" "mycel_core_web-builder:latest"
docker tag "$BUILDER_LOCAL" "${REGISTRY}/mycel_core_web-builder:latest"
docker tag "$RUNTIME_LOCAL" "mycel_core_web:latest"
docker tag "$RUNTIME_LOCAL" "${REGISTRY}/mycel_core_web:latest"

if [ "$PUSH" = "--push" ]; then
  echo "=== Pushing to ghcr ==="
  docker push "$BUILDER_REMOTE"
  docker push "$RUNTIME_REMOTE"
  docker push "${REGISTRY}/mycel_core_web-builder:latest"
  docker push "${REGISTRY}/mycel_core_web:latest"
fi

echo
echo "Built + tagged:"
echo "  $BUILDER_LOCAL  (+ :latest, + ghcr)"
echo "  $RUNTIME_LOCAL  (+ :latest, + ghcr)"
