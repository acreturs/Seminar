#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INPUT_DIR="${1:-${ROOT}/examples/custom_scene/images}"
NAME="${2:-custom_scene}"
OUTPUT_DIR="${3:-${ROOT}/data/processed/custom/${NAME}}"

if ! command -v ns-process-data >/dev/null 2>&1; then
  echo "ns-process-data is missing. Install/activate FlowR or Nerfstudio first." >&2
  exit 1
fi

if [[ ! -d "${INPUT_DIR}" ]]; then
  echo "Input image directory does not exist: ${INPUT_DIR}" >&2
  exit 1
fi

mkdir -p "$(dirname "${OUTPUT_DIR}")"
ns-process-data images \
  --data "${INPUT_DIR}" \
  --output-dir "${OUTPUT_DIR}" \
  --matching-method exhaustive

bash "${ROOT}/scripts/activate_dataset.sh" "${OUTPUT_DIR}"
echo "Custom scene processed at ${OUTPUT_DIR}"
