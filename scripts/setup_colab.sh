#!/usr/bin/env bash
# Colab bootstrap for the FlowR seminar workflow.
# Installs Nerfstudio + its CUDA stack, clones all comparison repos
# listed in configs/nerfstudio.yaml, and installs the lightweight extras
# (Nerfbusters extension, InstantSplat deps). Heavyweight methods
# (FlowR, ViewCrafter, GANeRF, ZeroNVS, Zip-NeRF) are cloned only;
# see their READMEs in external/ for full install steps.
#
# Usage:
#   bash scripts/setup_colab.sh            # full setup
#   SKIP_HEAVY=1 bash scripts/setup_colab.sh   # only Nerfstudio + Nerfbusters
#
# Designed for a fresh Colab runtime (Ubuntu 22.04, CUDA 12.x, Python 3.10/3.11).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

SKIP_HEAVY="${SKIP_HEAVY:-0}"
EXTERNAL="${ROOT}/external"
mkdir -p "${EXTERNAL}"

log() { printf "\n\033[1;34m[setup]\033[0m %s\n" "$*"; }

# ---------------------------------------------------------------------------
# 1. System packages: COLMAP + ffmpeg are needed by ns-process-data.
# ---------------------------------------------------------------------------
log "Installing system packages (colmap, ffmpeg, build tools)"
apt-get update -qq
apt-get install -y -qq \
  colmap ffmpeg git wget unzip \
  build-essential cmake ninja-build \
  libgl1 libglib2.0-0

# ---------------------------------------------------------------------------
# 2. Python deps for Nerfstudio. tinycudann needs the right torch+CUDA combo.
# ---------------------------------------------------------------------------
log "Installing PyTorch (CUDA 12.1 wheels)"
pip install --quiet --upgrade pip
pip install --quiet \
  torch==2.1.2+cu121 torchvision==0.16.2+cu121 \
  --extra-index-url https://download.pytorch.org/whl/cu121

log "Installing tiny-cuda-nn"
pip install --quiet ninja
pip install --quiet \
  git+https://github.com/NVlabs/tiny-cuda-nn/#subdirectory=bindings/torch

log "Installing Nerfstudio"
pip install --quiet nerfstudio

log "Installing notebook helpers (pyngrok, pyyaml, gdown)"
pip install --quiet pyngrok pyyaml gdown

# ---------------------------------------------------------------------------
# 3. Clone every public comparison repo into external/ (shallow).
# ---------------------------------------------------------------------------
clone_shallow() {
  local name="$1" url="$2" dir="$3"
  local target="${EXTERNAL}/${dir}"
  if [[ -d "${target}/.git" ]]; then
    log "skip clone ${name}: already present"
  else
    log "clone ${name}"
    git clone --depth 1 "${url}" "${target}"
  fi
}

clone_shallow nerfstudio   https://github.com/nerfstudio-project/nerfstudio.git nerfstudio
clone_shallow flowr        https://github.com/tobiasfshr/flowr.git              flowr
clone_shallow InstantSplat https://github.com/NVlabs/InstantSplat.git           InstantSplat
clone_shallow ViewCrafter  https://github.com/Drexubery/ViewCrafter.git         ViewCrafter
clone_shallow GANeRF       https://github.com/barbararoessle/ganerf.git         ganerf
clone_shallow Nerfbusters  https://github.com/ethanweber/nerfbusters.git        nerfbusters
clone_shallow ZeroNVS      https://github.com/kylesargent/ZeroNVS.git           ZeroNVS
clone_shallow ZipNeRF      https://github.com/jonbarron/camp_zipnerf.git        camp_zipnerf

# ---------------------------------------------------------------------------
# 4. Light installs that play nicely with the pip-installed Nerfstudio.
# ---------------------------------------------------------------------------
log "Installing Nerfbusters as a Nerfstudio extension"
pip install --quiet -e "${EXTERNAL}/nerfbusters" || \
  log "warning: nerfbusters extension install failed (continuing)"

log "Installing InstantSplat python deps (best-effort)"
if [[ -f "${EXTERNAL}/InstantSplat/requirements.txt" ]]; then
  pip install --quiet -r "${EXTERNAL}/InstantSplat/requirements.txt" || \
    log "warning: InstantSplat requirements partially failed"
fi

# ---------------------------------------------------------------------------
# 5. Heavyweight methods: cloned only, install steps left to their READMEs.
# ---------------------------------------------------------------------------
if [[ "${SKIP_HEAVY}" == "1" ]]; then
  log "SKIP_HEAVY=1 -> done"
  exit 0
fi

cat <<'NOTE'

[setup] Heavyweight methods are cloned but NOT auto-installed:
  - external/flowr        : run external/flowr/install.sh (needs conda + CUDA 12.2 + GCC 12)
  - external/ViewCrafter  : see external/ViewCrafter/README.md (large diffusion weights)
  - external/ganerf       : older CUDA stack, usually conflicts with Colab
  - external/ZeroNVS      : needs the zeronvs_diffusion submodule; pip install per its README
  - external/camp_zipnerf : JAX-based; pip install -r requirements.txt inside its dir

The Colab notebook runs all Nerfstudio-backed methods automatically.
Heavyweight methods are documented for the seminar comparison, but only
attempt them on Colab Pro / A100 or a local box.

NOTE

log "Done. Verify with: ns-train --help"
