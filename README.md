# FlowR Seminar Environment

This workspace is set up around `2504.01647v2.pdf`, **FlowR: Flowing from Sparse to Dense 3D Reconstructions**.

The goal is to keep paper reproduction and presentation examples manageable:

- `external/` contains FlowR and public comparison repos.
- `data/raw/` contains downloaded original datasets.
- `data/processed/` contains FlowR/Nerfstudio-ready datasets.
- `data/active` is a symlink to the dataset or scene currently being used.
- `outputs/` contains reconstructions, renders, metrics, and videos.

All of those large/generated paths are ignored by git.

## Quick Start

```bash
bash scripts/bootstrap_conda.sh
source .conda/etc/profile.d/conda.sh  # only needed when conda is not globally installed
conda activate flowr-lab
bash scripts/clone_repos.sh --all
bash scripts/download_flowr_assets.sh
```

Install FlowR's actual runtime environment:

```bash
bash scripts/install_flowr.sh
source .conda/etc/profile.d/conda.sh
conda activate flowr
```

FlowR's installer creates a separate `flowr` conda environment. The `flowr-lab` env is only for orchestration, downloads, and lightweight helper scripts.

## Paper Baselines

Main comparisons from the paper:

- DL3DV140 sparse-view: Splatfacto, InstantSplat, ViewCrafter, FlowR initial, FlowR, FlowR++.
- ScanNet++ dense-view: Splatfacto, GANeRF, FlowR initial, FlowR, GANeRF with GAN, FlowR++.
- Nerfbusters: Splatfacto, Nerfacto, Nerfbusters, FlowR initial, FlowR, FlowR with opacity thresholding.
- Appendix Mip-NeRF 360 few-view: Zip-NeRF, ZeroNVS, ReconFusion, CAT3D, FlowR.

See `docs/comparison_methods.md` for repo mapping and closed-source notes.

## Datasets

The full paper-scale datasets are very large and some require login/approval:

- DL3DV-140 benchmark: about 2.1 TB full, or about 100-150 GB for 960P images.
- DL3DV-10K training data: 730 GB to many TB depending on resolution.
- ScanNet++: registration required; 371 GB for DSLR 2MP only, about 1.5 TB default.
- Nerfbusters: data linked from its repo via Google Drive.
- Mip-NeRF 360: public but large.

This machine currently should not download all paper datasets at once. Use the scripts for targeted subsets and keep full datasets on an external disk if needed. See `docs/datasets.md` and `docs/paper_resources_and_dataset_generation.md`.

The current local download status and custom dataset-generation workflow are documented in `docs/paper_resources_and_dataset_generation.md`.

The 30-minute seminar outline is in `docs/flowr_30min_presentation_outline.md`.

For selected DL3DV downloads after Hugging Face access approval:

```bash
export HF_TOKEN=<your_huggingface_token>
bash scripts/download_flowr_assets.sh
HASH=<scene_hash> bash scripts/download_dl3dv.sh benchmark-scene
SUBSET=1K RESOLUTION=480P bash scripts/download_dl3dv.sh 10k
```

## FlowR Dataset Prep

After activating the `flowr` env:

```bash
VIEWS=12 bash scripts/prepare_flowr_dl3dv.sh
VIEWS=24 bash scripts/prepare_flowr_dl3dv.sh
```

For ScanNet++ after downloading it manually from the official portal:

```bash
SCANNETPP_ROOT=/path/to/scannetpp bash scripts/prepare_flowr_scannetpp.sh
```

Activate any processed dataset or scene:

```bash
bash scripts/activate_dataset.sh data/processed/flowr/dl3dv140-12v
```

## Custom Examples

Put overlapping photos into `examples/custom_scene/images/`, then:

```bash
conda activate flowr
bash scripts/process_custom_images.sh examples/custom_scene/images my_scene
bash scripts/run_flowr_stage1.sh data/processed/custom/my_scene
```

The Stage 1 command writes a config like `outputs/my_scene/splatfacto-instant/<timestamp>/config.yml`.
Use that config to render the trained 3DGS model:

```bash
STAGE1_CONFIG=$(find outputs -path '*splatfacto-instant*/config.yml' | sort | tail -n 1)
bash scripts/render_flowr.sh "$STAGE1_CONFIG"
```

For a plain Nerfstudio baseline:

```bash
bash scripts/run_splatfacto_baseline.sh data/processed/custom/my_scene
```

After Stage 1 and a FlowR model config are available, run the refined reconstruction path:

```bash
bash scripts/run_flowr_stage2.sh <stage1_config.yml> <scene_dir> <flowr_model_config.yaml> outputs/flowr/my_scene_stage2
```

The refined model config can be rendered the same way:

```bash
bash scripts/render_flowr.sh <stage2_config.yml>
```

## Checks

```bash
.conda/bin/python scripts/check_setup.py
```

`ns-process-data` and `ns-train` are available only after the FlowR/Nerfstudio runtime is installed and the `flowr` conda environment is active.
