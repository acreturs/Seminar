#!/usr/bin/env bash
set -euo pipefail

CONFIG="${1:-}"

if [[ -z "${CONFIG}" || ! -f "${CONFIG}" ]]; then
  echo "Usage: scripts/evaluate_flowr.sh <path_to_config.yml>" >&2
  exit 1
fi

python -m flowr.eval --load-config "${CONFIG}"
