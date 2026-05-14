#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT}/envs/flowr-lab.yml"

export HOME="${ROOT}"
export CONDA_PKGS_DIRS="${ROOT}/.conda/pkgs"
export CONDA_ENVS_DIRS="${ROOT}/.conda/envs"

if command -v conda >/dev/null 2>&1; then
  CONDA_BASE="$(conda info --base)"
else
  INSTALLER="${ROOT}/Miniconda3-latest-Linux-x86_64.sh"
  PREFIX="${ROOT}/.conda"
  if [[ ! -x "${INSTALLER}" && ! -f "${INSTALLER}" ]]; then
    echo "No conda found and ${INSTALLER} is missing." >&2
    exit 1
  fi
  if [[ -d "${PREFIX}" && ! -x "${PREFIX}/bin/conda" ]]; then
    mv "${PREFIX}" "${PREFIX}.broken.$(date +%s)"
  fi
  if [[ ! -d "${PREFIX}" ]]; then
    bash "${INSTALLER}" -b -p "${PREFIX}"
  fi
  CONDA_BASE="${PREFIX}"
fi

# shellcheck source=/dev/null
source "${CONDA_BASE}/etc/profile.d/conda.sh"

if conda env list | awk '{print $1}' | grep -qx "flowr-lab"; then
  conda env update -n flowr-lab -f "${ENV_FILE}" --prune
else
  conda env create -f "${ENV_FILE}"
fi

echo "Run:"
echo "  source ${CONDA_BASE}/etc/profile.d/conda.sh"
echo "  conda activate flowr-lab"
