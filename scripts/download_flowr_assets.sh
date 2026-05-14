#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET_DIR="${FLOWR_ASSETS:-${ROOT}/data/assets}"
SCALE_ZIP="${ASSET_DIR}/dl3dv_scales.zip"
SCALE_DIR="${SCALE_DIR:-${ASSET_DIR}/dl3dv_scales}"
DL3DV_SCRIPT="${ASSET_DIR}/dl3dv_10k_download.py"
DL3DV_BENCH_SCRIPT="${ASSET_DIR}/dl3dv_benchmark_download.py"

mkdir -p "${ASSET_DIR}"

if [[ -f "${SCALE_ZIP}" ]] && unzip -tq "${SCALE_ZIP}" >/dev/null 2>&1; then
  echo "[skip] ${SCALE_ZIP} already exists"
else
  rm -f "${SCALE_ZIP}" "${SCALE_ZIP}.tmp"
  wget -O "${SCALE_ZIP}.tmp" "https://github.com/tobiasfshr/flowr/raw/main/assets/dl3dv_scales.zip"
  unzip -tq "${SCALE_ZIP}.tmp" >/dev/null
  mv "${SCALE_ZIP}.tmp" "${SCALE_ZIP}"
fi

mkdir -p "${SCALE_DIR}"
unzip -oq "${SCALE_ZIP}" -d "${SCALE_DIR}"

if [[ ! -s "${DL3DV_SCRIPT}" ]]; then
  rm -f "${DL3DV_SCRIPT}"
  wget -q -O "${DL3DV_SCRIPT}" "https://raw.githubusercontent.com/DL3DV-10K/Dataset/main/scripts/download.py"
fi

if [[ ! -s "${DL3DV_BENCH_SCRIPT}" ]]; then
  rm -f "${DL3DV_BENCH_SCRIPT}"
  HF_WGET_ARGS=()
  if [[ -n "${HF_TOKEN:-}" ]]; then
    HF_WGET_ARGS+=(--header "Authorization: Bearer ${HF_TOKEN}")
  fi
  if ! wget -q "${HF_WGET_ARGS[@]}" -O "${DL3DV_BENCH_SCRIPT}.tmp" "https://huggingface.co/datasets/DL3DV/DL3DV-Benchmark/resolve/main/download.py"; then
    rm -f "${DL3DV_BENCH_SCRIPT}.tmp"
    echo "DL3DV benchmark downloader needs Hugging Face access. Set HF_TOKEN after access approval, then rerun this script." >&2
  else
    mv "${DL3DV_BENCH_SCRIPT}.tmp" "${DL3DV_BENCH_SCRIPT}"
  fi
fi

echo "Assets ready in ${ASSET_DIR}"
