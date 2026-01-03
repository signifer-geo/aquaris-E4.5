#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-krillin}"
MODE="${2:-n}"   # "n" is what README uses; keep default
WHAT="${3:-k}"   # "k" is what README uses; keep default

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

if [[ ! -x ./makeMtk ]]; then
  echo "ERROR: ./makeMtk not found or not executable"
  exit 1
fi

echo "[INFO] Building target=$TARGET mode=$MODE what=$WHAT"
echo "[INFO] Command: ./makeMtk -t ${TARGET} ${MODE} ${WHAT}"

# Make builds more deterministic across systems
export LC_ALL=C
export LANG=C
export TZ=UTC

./makeMtk -t "${TARGET}" "${MODE}" "${WHAT}"

echo "[INFO] Build finished."

# Try to locate common kernel outputs and print them for CI logs
echo "[INFO] Searching for likely artifacts..."
find . -type f \( \
    -name "zImage" -o -name "Image" -o -name "Image.gz" -o -name "*.dtb" -o -name "*.ko" \
  \) 2>/dev/null | head -n 200 || true

