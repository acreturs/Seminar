#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCANNETPP_ROOT="${SCANNETPP_ROOT:-${ROOT}/data/raw/scannetpp}"
SPLIT="${SPLIT:-val}"
WORK_DIR="${WORK_DIR:-${ROOT}/scratch/flowr/scannetpp-${SPLIT}}"
DATA_DIR="${DATA_DIR:-${ROOT}/data/processed/flowr/scannetpp-${SPLIT}}"

if [[ ! -d "${SCANNETPP_ROOT}" ]]; then
  echo "SCANNETPP_ROOT does not exist: ${SCANNETPP_ROOT}" >&2
  echo "Download ScanNet++ manually after registering at the official site, then set SCANNETPP_ROOT." >&2
  exit 1
fi

mkdir -p "${WORK_DIR}" "${DATA_DIR}"

if [[ "${SPLIT}" == "val" ]]; then
  python -m flowr.prepare_scannetpp generate \
    "${SCANNETPP_ROOT}" "${WORK_DIR}" "${DATA_DIR}" --split val --skip_other
  python -m flowr.prepare_scannetpp check "${SCANNETPP_ROOT}" "${DATA_DIR}" --split val
else
  python -m flowr.prepare_scannetpp generate \
    "${SCANNETPP_ROOT}" "${WORK_DIR}" "${DATA_DIR}" --split "${SPLIT}"
  python -m flowr.prepare_scannetpp check "${SCANNETPP_ROOT}" "${DATA_DIR}" --split "${SPLIT}"
fi

bash "${ROOT}/scripts/activate_dataset.sh" "${DATA_DIR}"
