#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLOWR_REPO="${FLOWR_REPO:-${ROOT}/external/flowr}"
CONDA_ROOT="${ROOT}/.conda"

export HOME="${ROOT}"
export CONDA_PKGS_DIRS="${CONDA_ROOT}/pkgs"
export CONDA_ENVS_DIRS="${CONDA_ROOT}/envs"

if [[ ! -d "${FLOWR_REPO}/.git" ]]; then
  echo "FlowR repo is missing. Run: bash scripts/clone_repos.sh --primary" >&2
  exit 1
fi

if ! command -v conda >/dev/null 2>&1; then
  if [[ -f "${CONDA_ROOT}/etc/profile.d/conda.sh" ]]; then
    # shellcheck source=/dev/null
    source "${CONDA_ROOT}/etc/profile.d/conda.sh"
  else
    echo "Conda is missing. Run: bash scripts/bootstrap_conda.sh" >&2
    exit 1
  fi
fi

cd "${FLOWR_REPO}"
bash install.sh

echo "FlowR installer finished. Run: conda activate flowr"
