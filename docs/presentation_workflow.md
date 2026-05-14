# Presentation Example Workflow

Use this when you want to make your own FlowR examples for slides.

## 1. Set Up The Lab Environment

```bash
bash scripts/bootstrap_conda.sh
source .conda/etc/profile.d/conda.sh
conda activate flowr-lab
bash scripts/clone_repos.sh --all
```

## 2. Install FlowR

```bash
bash scripts/install_flowr.sh
conda activate flowr
```

## 3. Fetch Small FlowR Assets

```bash
bash scripts/download_flowr_assets.sh
```

## 4. Prepare A Paper Benchmark Split

For DL3DV-140:

```bash
VIEWS=12 bash scripts/prepare_flowr_dl3dv.sh
VIEWS=24 bash scripts/prepare_flowr_dl3dv.sh
```

For ScanNet++ validation after manual dataset download/registration:

```bash
SCANNETPP_ROOT=/path/to/scannetpp bash scripts/prepare_flowr_scannetpp.sh
```

## 5. Process Your Own Images

Put images in `examples/custom_scene/images/`, then run:

```bash
bash scripts/process_custom_images.sh examples/custom_scene/images my_scene
bash scripts/run_flowr_stage1.sh data/processed/custom/my_scene
```

This uses Nerfstudio/COLMAP preprocessing, so it needs enough overlap between images for camera poses.

## 6. Baseline Splatfacto Example

```bash
bash scripts/run_splatfacto_baseline.sh data/processed/custom/my_scene
```

Set `METHOD=nerfacto` to run the Nerfstudio Nerfacto baseline instead.

## 7. FlowR Stage 2

After Stage 1 produces a config, and after you have a FlowR model config/checkpoint:

```bash
bash scripts/run_flowr_stage2.sh \
  outputs/path/to/stage1/config.yml \
  data/processed/custom/my_scene \
  outputs/path/to/flowr_model/config.yaml \
  outputs/flowr/my_scene_stage2
```
