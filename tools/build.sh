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


# --- ensure makeMtk.ini exists (MTK scripts expect it) ---
INI="./makeMtk.ini"

# If something weird exists (e.g., directory), remove it.
if [[ -e "$INI" && ! -f "$INI" ]]; then
  echo "[WARN] $INI exists but is not a regular file. Removing it."
  rm -rf "$INI"
fi

# If missing, create a minimal one.
if [[ ! -f "$INI" ]]; then
  echo "[INFO] $INI missing. Creating a minimal one."

  # Determine whether "krillin" is a real project folder
  if [[ -f "mediatek/config/${TARGET}/ProjectConfig.mk" ]]; then
    REAL_PROJECT="${TARGET}"
  else
    # Try to auto-detect a project whose ProjectConfig.mk mentions "krillin"
    REAL_PROJECT="$(grep -RIl --max-count=1 -i "krillin" mediatek/config/*/ProjectConfig.mk 2>/dev/null \
      | sed -E 's#^mediatek/config/([^/]+)/ProjectConfig\.mk$#\1#' \
      | head -n 1 || true)"

    if [[ -z "$REAL_PROJECT" ]]; then
      echo "[ERROR] Could not find mediatek/config/${TARGET}/ProjectConfig.mk"
      echo "[ERROR] and could not auto-detect a project mentioning '${TARGET}'."
      echo "[INFO] Available projects are:"
      ls -1 mediatek/config | head -n 200
      exit 13
    fi
  fi

  cat > "$INI" <<EOF
# Auto-generated for reproducible builds/CI
# Alias mapping (used when project folder doesn't exist):
${TARGET} = ${REAL_PROJECT}

# State keys expected by MTK scripts:
project = ${REAL_PROJECT}
build_mode = eng
EOF

  echo "[INFO] Using project: ${REAL_PROJECT}"
fi
# --- end ensure makeMtk.ini exists ---




./makeMtk -t "${TARGET}" "${MODE}" "${WHAT}"

echo "[INFO] Build finished."

# Try to locate common kernel outputs and print them for CI logs
echo "[INFO] Searching for likely artifacts..."
find . -type f \( \
    -name "zImage" -o -name "Image" -o -name "Image.gz" -o -name "*.dtb" -o -name "*.ko" \
  \) 2>/dev/null | head -n 200 || true

