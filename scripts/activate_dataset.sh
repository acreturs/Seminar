#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-}"

if [[ -z "${TARGET}" ]]; then
  echo "Usage: scripts/activate_dataset.sh <processed_dataset_or_scene_dir>" >&2
  exit 1
fi

if [[ ! -e "${TARGET}" ]]; then
  echo "Dataset path does not exist: ${TARGET}" >&2
  exit 1
fi

ABS_TARGET="$(realpath "${TARGET}")"
ln -sfn "${ABS_TARGET}" "${ROOT}/data/active"
cat > "${ROOT}/data/active_dataset.env" <<EOF
FLOWR_DATA=${ABS_TARGET}
EOF

echo "Active dataset: ${ABS_TARGET}"
