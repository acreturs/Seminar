#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCENE_DIR="${1:-${FLOWR_DATA:-${ROOT}/data/active}}"
OUTPUT_DIR="${OUTPUT_DIR:-${ROOT}/outputs/nerfstudio/splatfacto}"
METHOD="${METHOD:-splatfacto}"

if ! command -v ns-train >/dev/null 2>&1; then
  echo "ns-train is missing. Activate a Nerfstudio-compatible environment first." >&2
  exit 1
fi

if [[ ! -e "${SCENE_DIR}" ]]; then
  echo "Scene/dataset path does not exist: ${SCENE_DIR}" >&2
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"
ns-train "${METHOD}" --output-dir "${OUTPUT_DIR}" --data "${SCENE_DIR}"
