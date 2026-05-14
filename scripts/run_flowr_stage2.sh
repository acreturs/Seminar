#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

STAGE1_CONFIG="${1:-}"
ORIGINAL_SCENE_DIR="${2:-${FLOWR_DATA:-${ROOT}/data/active}}"
FLOWR_MODEL_CONFIG="${3:-}"
STAGE2_SCENE_DIR="${4:-${ROOT}/outputs/flowr/stage2_scene}"
NUM_VIEWS="${NUM_VIEWS:-64}"
METHOD="${METHOD:-interpolation}"
ITERATIONS="${ITERATIONS:-30001}"

if [[ -z "${STAGE1_CONFIG}" || -z "${FLOWR_MODEL_CONFIG}" ]]; then
  cat >&2 <<'USAGE'
Usage:
  scripts/run_flowr_stage2.sh <stage1_config.yml> <original_scene_dir> <flowr_model_config.yaml> [stage2_scene_dir]

Environment:
  NUM_VIEWS   Number of generated target views. Default: 64.
  METHOD      View selection method: interpolation or perturbation. Default: interpolation.
  ITERATIONS  Refined reconstruction iterations. Default: 30001.
USAGE
  exit 1
fi

if [[ ! -f "${STAGE1_CONFIG}" ]]; then
  echo "Stage 1 config does not exist: ${STAGE1_CONFIG}" >&2
  exit 1
fi

if [[ ! -e "${ORIGINAL_SCENE_DIR}" ]]; then
  echo "Original scene dir does not exist: ${ORIGINAL_SCENE_DIR}" >&2
  exit 1
fi

if [[ ! -f "${FLOWR_MODEL_CONFIG}" ]]; then
  echo "FlowR model config does not exist: ${FLOWR_MODEL_CONFIG}" >&2
  exit 1
fi

python -m flowr.generate_dataset \
  --model "${STAGE1_CONFIG}" \
  --input_dir "${ORIGINAL_SCENE_DIR}" \
  --output_dir "${STAGE2_SCENE_DIR}" \
  --num_views "${NUM_VIEWS}" \
  --method "${METHOD}"

python -m flowr.generate_views \
  --config "${FLOWR_MODEL_CONFIG}" \
  --input_dir "${STAGE2_SCENE_DIR}" \
  --num_views "${NUM_VIEWS}"

python -m flowr.reconstruct splatfacto-default \
  --max-num-iterations "${ITERATIONS}" \
  image \
  --data "${STAGE2_SCENE_DIR}" \
  --use-generated True
