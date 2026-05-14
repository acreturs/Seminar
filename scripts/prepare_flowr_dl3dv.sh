#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VIEWS="${VIEWS:-12}"
WORK_DIR="${WORK_DIR:-${ROOT}/scratch/flowr/dl3dv140-${VIEWS}v}"
DATA_DIR="${DATA_DIR:-${ROOT}/data/processed/flowr/dl3dv140-${VIEWS}v}"
SCALE_DIR="${SCALE_DIR:-${ROOT}/data/assets/dl3dv_scales}"

if [[ "${VIEWS}" != "12" && "${VIEWS}" != "24" ]]; then
  echo "VIEWS must be 12 or 24 for the paper's DL3DV-140 evaluation split." >&2
  exit 1
fi

if [[ ! -d "${SCALE_DIR}" ]]; then
  echo "Scale factors are missing. Run: bash scripts/download_flowr_assets.sh" >&2
  exit 1
fi

mkdir -p "${WORK_DIR}" "${DATA_DIR}"

python -m flowr.prepare_dl3dv generate \
  "${WORK_DIR}" "${DATA_DIR}" "${SCALE_DIR}" \
  --subset 140 --views "${VIEWS}" --skip_other

python -m flowr.prepare_dl3dv check "${DATA_DIR}" --subset 140 --views "${VIEWS}"

bash "${ROOT}/scripts/activate_dataset.sh" "${DATA_DIR}"
