#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="all"
WITH_SUBMODULES=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      MODE="all"
      ;;
    --primary)
      MODE="primary"
      ;;
    --with-submodules)
      WITH_SUBMODULES=1
      ;;
    -h|--help)
      cat <<'USAGE'
Usage: scripts/clone_repos.sh [--all|--primary] [--with-submodules]

Clones the public FlowR comparison repositories into external/.
Closed-source comparison methods are documented in docs/comparison_methods.md.
USAGE
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

mkdir -p "${ROOT}/external"

clone_repo() {
  local name="$1"
  local url="$2"
  local dir="$3"
  local target="${ROOT}/${dir}"

  if [[ -d "${target}/.git" ]]; then
    echo "[skip] ${name}: ${dir} already exists"
  else
    echo "[clone] ${name}: ${url}"
    git clone --depth 1 "${url}" "${target}"
  fi

  if [[ "${WITH_SUBMODULES}" == "1" ]]; then
    if [[ -f "${target}/.gitmodules" ]]; then
      if [[ "${name}" == "ZeroNVS" ]]; then
        git -C "${target}" submodule set-url zeronvs_diffusion "https://github.com/kylesargent/zeronvs_diffusion.git"
      fi
      echo "[submodules] ${name}"
      git -C "${target}" submodule update --init --recursive --depth 1
    else
      echo "[submodules] ${name}: none declared"
    fi
  fi
}

clone_repo "flowr" "https://github.com/tobiasfshr/flowr.git" "external/flowr"

if [[ "${MODE}" == "all" ]]; then
  clone_repo "nerfstudio" "https://github.com/nerfstudio-project/nerfstudio.git" "external/nerfstudio"
  clone_repo "InstantSplat" "https://github.com/NVlabs/InstantSplat.git" "external/InstantSplat"
  clone_repo "ViewCrafter" "https://github.com/Drexubery/ViewCrafter.git" "external/ViewCrafter"
  clone_repo "GANeRF" "https://github.com/barbararoessle/ganerf.git" "external/ganerf"
  clone_repo "Nerfbusters" "https://github.com/ethanweber/nerfbusters.git" "external/nerfbusters"
  clone_repo "ZeroNVS" "https://github.com/kylesargent/ZeroNVS.git" "external/ZeroNVS"
  clone_repo "CamP Zip-NeRF" "https://github.com/jonbarron/camp_zipnerf.git" "external/camp_zipnerf"
  clone_repo "MultiNeRF" "https://github.com/google-research/multinerf.git" "external/multinerf"
  clone_repo "ScanNet++ toolbox" "https://github.com/scannetpp/scannetpp.git" "external/scannetpp"
  clone_repo "DL3DV dataset tooling" "https://github.com/DL3DV-10K/Dataset.git" "external/DL3DV-Dataset"
fi

echo "Clone step complete."
