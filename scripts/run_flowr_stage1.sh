#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCENE_DIR="${1:-${FLOWR_DATA:-${ROOT}/data/active}}"
ITERATIONS="${ITERATIONS:-5001}"

if [[ ! -e "${SCENE_DIR}" ]]; then
  echo "Scene/dataset path does not exist: ${SCENE_DIR}" >&2
  echo "Pass a scene dir or activate one with scripts/activate_dataset.sh." >&2
  exit 1
fi

python -m flowr.reconstruct splatfacto-instant \
  --pipeline.datamanager.dataparser.data "${SCENE_DIR}" \
  --max-num-iterations "${ITERATIONS}"
