#!/usr/bin/env bash
set -euo pipefail

ENGINE="${ENGINE:-docker}"   # or: podman
IMAGE="${IMAGE:-aquaris-e45-kernel:local}"
TARGET="${1:-krillin}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

$ENGINE build -t "$IMAGE" .

# Mount repo and run build inside container
$ENGINE run --rm -it \
  -v "$ROOT:/work" \
  -w /work \
  "$IMAGE" \
  bash -lc "./tools/build.sh ${TARGET}"

