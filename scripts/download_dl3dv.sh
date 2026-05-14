#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET_DIR="${FLOWR_ASSETS:-${ROOT}/data/assets}"
MODE="${1:-help}"

TENK_SCRIPT="${ASSET_DIR}/dl3dv_10k_download.py"
BENCH_SCRIPT="${ASSET_DIR}/dl3dv_benchmark_download.py"
PYTHON_BIN="${PYTHON:-}"

if [[ -z "${PYTHON_BIN}" ]]; then
  if command -v python >/dev/null 2>&1; then
    PYTHON_BIN="python"
  elif [[ -x "${ROOT}/.conda/envs/flowr-lab/bin/python" ]]; then
    PYTHON_BIN="${ROOT}/.conda/envs/flowr-lab/bin/python"
  elif [[ -x "${ROOT}/.conda/bin/python" ]]; then
    PYTHON_BIN="${ROOT}/.conda/bin/python"
  else
    echo "Could not find python. Activate flowr-lab or set PYTHON=/path/to/python." >&2
    exit 1
  fi
fi

usage() {
  cat <<'USAGE'
Usage:
  scripts/download_dl3dv.sh 10k
  scripts/download_dl3dv.sh benchmark-scene
  scripts/download_dl3dv.sh benchmark-full-960p

Environment:
  ODIR        Output directory. Defaults depend on mode.
  SUBSET      DL3DV-10K subset for mode=10k. Default: 1K.
  RESOLUTION  DL3DV-10K resolution for mode=10k. Default: 480P.
  FILE_TYPE   DL3DV-10K file type for mode=10k. Default: images+poses.
  HASH        Scene hash for mode=benchmark-scene.

Notes:
  - Set HF_TOKEN after Hugging Face access approval before benchmark downloads.
  - The 960P benchmark is about 100-150 GB; the full benchmark is about 2.1 TB.
USAGE
}

ensure_assets() {
  if [[ ! -s "${TENK_SCRIPT}" || ( "${MODE}" == benchmark* && ! -s "${BENCH_SCRIPT}" ) ]]; then
    bash "${ROOT}/scripts/download_flowr_assets.sh" || true
  fi
}

case "${MODE}" in
  10k)
    ensure_assets
    if [[ ! -s "${TENK_SCRIPT}" ]]; then
      echo "Missing ${TENK_SCRIPT}" >&2
      exit 1
    fi
    ODIR="${ODIR:-${ROOT}/data/raw/dl3dv-10k}"
    SUBSET="${SUBSET:-1K}"
    RESOLUTION="${RESOLUTION:-480P}"
    FILE_TYPE="${FILE_TYPE:-images+poses}"
    mkdir -p "${ODIR}"
    "${PYTHON_BIN}" "${TENK_SCRIPT}" \
      --odir "${ODIR}" \
      --subset "${SUBSET}" \
      --resolution "${RESOLUTION}" \
      --file_type "${FILE_TYPE}" \
      --clean_cache
    ;;
  benchmark-scene)
    ensure_assets
    if [[ ! -s "${BENCH_SCRIPT}" ]]; then
      echo "Missing ${BENCH_SCRIPT}; set HF_TOKEN after Hugging Face access approval and rerun scripts/download_flowr_assets.sh." >&2
      exit 1
    fi
    if [[ -z "${HASH:-}" ]]; then
      echo "Set HASH=<dl3dv_scene_hash> for benchmark-scene mode." >&2
      exit 1
    fi
    ODIR="${ODIR:-${ROOT}/data/raw/dl3dv-benchmark}"
    mkdir -p "${ODIR}"
    cd "${ODIR}"
    "${PYTHON_BIN}" "${BENCH_SCRIPT}" --subset hash --hash "${HASH}" --only_level4 --clean_cache
    ;;
  benchmark-full-960p)
    ensure_assets
    if [[ ! -s "${BENCH_SCRIPT}" ]]; then
      echo "Missing ${BENCH_SCRIPT}; set HF_TOKEN after Hugging Face access approval and rerun scripts/download_flowr_assets.sh." >&2
      exit 1
    fi
    ODIR="${ODIR:-${ROOT}/data/raw/dl3dv-benchmark-960p}"
    mkdir -p "${ODIR}"
    cd "${ODIR}"
    "${PYTHON_BIN}" "${BENCH_SCRIPT}" --subset full --only_level4 --clean_cache
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    echo "Unknown mode: ${MODE}" >&2
    usage >&2
    exit 1
    ;;
esac
