#!/usr/bin/env bash
# Train one Nerfstudio-backed method on a processed dataset.
#
# Usage:
#   bash scripts/run_nerfstudio.sh <method> <data_dir> [iterations] [output_dir]
#
# Examples:
#   bash scripts/run_nerfstudio.sh splatfacto data/custom/processed
#   bash scripts/run_nerfstudio.sh nerfacto   data/demo/garden  10000 outputs/garden
#
# The viewer URL is printed by ns-train; expose it from Colab via scripts/tunnel.py.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

METHOD="${1:?method required (e.g. splatfacto, nerfacto, instant-ngp, nerfbusters)}"
DATA="${2:?data dir required (output of ns-process-data)}"
ITERATIONS="${3:-30000}"
OUTPUT_DIR="${4:-${ROOT}/outputs/${METHOD}}"
VIEWER_PORT="${VIEWER_PORT:-7007}"

if ! command -v ns-train >/dev/null 2>&1; then
  echo "ns-train not on PATH. Run scripts/setup_colab.sh first." >&2
  exit 1
fi

if [[ ! -d "${DATA}" ]]; then
  echo "Data dir not found: ${DATA}" >&2
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"

echo "[run] method=${METHOD} data=${DATA} iter=${ITERATIONS} out=${OUTPUT_DIR}"

ns-train "${METHOD}" \
  --data "${DATA}" \
  --output-dir "${OUTPUT_DIR}" \
  --max-num-iterations "${ITERATIONS}" \
  --viewer.websocket-port "${VIEWER_PORT}" \
  --viewer.make-share-url False
