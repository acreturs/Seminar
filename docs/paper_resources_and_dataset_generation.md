# FlowR Paper Resources And Dataset Generation

Stand: 2026-05-14

Diese Datei trennt bewusst zwischen heruntergeladenen Ressourcen, blockierten Full-Scale-Datasets und dem Workflow, mit dem du eigene Datensaetze fuer FlowR/Nerfstudio erzeugen kannst.

## Local Status

| Resource | Paper role | Local status | Notes |
| --- | --- | --- | --- |
| FlowR code | Proposed method | Downloaded in `external/flowr` | Official implementation. The public release trains/infers an SD3-based FlowR variant; the paper model used a Meta-internal image model. |
| Baseline/tool repos | Comparisons and tooling | Downloaded in `external/` | Includes Nerfstudio, InstantSplat, ViewCrafter, GANeRF, Nerfbusters, ZeroNVS, CamP/Zip-NeRF, MultiNeRF, ScanNet++ toolbox, and DL3DV tooling. |
| FlowR DL3DV scale factors | Dataset prep asset | Downloaded in `data/assets/dl3dv_scales` | Needed by FlowR DL3DV preparation. |
| DL3DV-10K downloader | Dataset download helper | Downloaded as `data/assets/dl3dv_10k_download.py` | Needs Hugging Face access for actual data. |
| DL3DV-140 benchmark | Main sparse-view benchmark | Not downloaded | Hugging Face login/access required. Full benchmark is about 2.1 TB; 960P-only is about 100-150 GB. |
| DL3DV-10K | FlowR training source | Not downloaded | Full 480P images+poses are about 730 GB, larger than the current free space if downloaded completely. Selected scenes/subsets are possible after access approval. |
| ScanNet++ | Dense-view eval and training source | Not downloaded | Official registration/login required. DSLR 2MP alone is about 371 GB; default release is about 1.5 TB. |
| Nerfbusters captures | Dense-view benchmark raw videos | Downloaded and extracted in `data/raw/nerfbusters/nerfbusters-captures` | Scenes: aloe, art, car, century, flowers, garbage, picnic, pikachu, pipe, plant, roses, table. |
| Nerfbusters processed dataset | Dense-view benchmark processed data | Downloaded as `data/raw/nerfbusters/nerfbusters-dataset.zip` | Kept zipped to save space. Extract when needed. |
| Mip-NeRF 360 | Appendix few-view benchmark | Downloaded as `data/raw/mipnerf360/360_v2.zip` | Official ZIP contains bicycle, bonsai, counter, garden, kitchen, room, stump. Flowers and treehill are placeholders that say the authors cannot publicly share those scenes. |
| ReconFusion, CAT3D | Appendix closed-source comparisons | Not cloned | FlowR compares against provided splits/results; no public runnable clone is available in this workspace. |
| ShapeNetCore.v2 | Nerfbusters diffusion model training data | Not downloaded | Only needed if you train the Nerfbusters local 3D diffusion prior, not for FlowR evaluation. Requires ShapeNet account. |

## Useful Links

- FlowR project: https://tobiasfshr.github.io/pub/flowr
- FlowR code: https://github.com/tobiasfshr/flowr
- DL3DV-10K project: https://dl3dv-10k.github.io/DL3DV-10K/
- DL3DV-10K tooling: https://github.com/DL3DV-10K/Dataset
- DL3DV benchmark/data on Hugging Face: https://huggingface.co/DL3DV
- ScanNet++ documentation: https://scannetpp.mlsg.cit.tum.de/scannetpp/documentation
- Nerfbusters code/data: https://github.com/ethanweber/nerfbusters
- Mip-NeRF 360 dataset: https://jonbarron.info/mipnerf360/

## Commands To Continue

Extract downloaded public data only when you need it:

```bash
unzip -q data/raw/mipnerf360/360_v2.zip -d data/raw/mipnerf360/extracted
unzip -q data/raw/nerfbusters/nerfbusters-dataset.zip -d data/raw/nerfbusters
```

For DL3DV access, request access on Hugging Face first, then provide a token:

```bash
export HF_TOKEN=<your_huggingface_token>
```

Download one selected DL3DV-10K scene when you know its hash:

```bash
.conda/envs/flowr-lab/bin/python data/assets/dl3dv_10k_download.py \
  --odir data/raw/dl3dv-10k \
  --subset 1K \
  --resolution 480P \
  --file_type images+poses \
  --hash <scene_hash> \
  --clean_cache
```

Download the first DL3DV-10K 1K batch only if you have enough disk space and access:

```bash
SUBSET=1K RESOLUTION=480P bash scripts/download_dl3dv.sh 10k
```

Do not start full DL3DV-10K or ScanNet++ downloads on this disk without an external drive. Current free space after the public downloads is enough for selected scenes/subsets, but far below the combined full paper-scale training and evaluation data requirements.

## How To Generate Your Own Dataset

There are two useful meanings of "generate a dataset" here.

The practical seminar version is: capture your own scene and convert it into a Nerfstudio/FlowR-ready scene. This is enough for a demo reconstruction.

The paper-scale version is: generate FlowR training pairs `(bad initial rendering, ground-truth image)` from dense source sequences. This is what the authors did at scale to train the flow model.

## Practical Custom Scene Dataset

Capture guidelines:

- Use a static scene. Moving people, moving screens, plants in wind, and changing light make 3DGS and COLMAP worse.
- Take 30-100 overlapping images, or extract frames from a smooth video. For a sparse-view demo, later subsample to 12 or 24 views.
- Keep 60-80% overlap between neighboring views.
- Walk an arc or loop around the subject; include height variation, but avoid huge jumps between consecutive views.
- Lock exposure/focus if possible. Avoid motion blur and severe overexposure.
- Include textured geometry. Textureless white walls, glass, mirrors, and shiny metal are hard cases.

Process images:

```bash
mkdir -p examples/custom_scene/images
# Put JPG/PNG images into examples/custom_scene/images first.

source .conda/etc/profile.d/conda.sh
conda activate flowr
bash scripts/process_custom_images.sh examples/custom_scene/images my_scene
```

The script writes:

```text
data/processed/custom/my_scene/
  images/
  transforms.json
```

Run a first reconstruction:

```bash
bash scripts/run_flowr_stage1.sh data/processed/custom/my_scene
```

Run a simple baseline:

```bash
bash scripts/run_splatfacto_baseline.sh data/processed/custom/my_scene
```

If `ns-process-data` or `ns-train` is missing, install the FlowR runtime first:

```bash
bash scripts/install_flowr.sh
source .conda/etc/profile.d/conda.sh
conda activate flowr
```

## Paper-Style FlowR Pair Dataset

This is the pipeline the paper uses conceptually.

1. Start with a dense posed image sequence, for example DL3DV-10K or ScanNet++.
2. Select sparse source views. FlowR uses 6-36 equally spaced source views for DL3DV-10K; for ScanNet++ it samples keyframes and nearby training frames.
3. Build an initial reconstruction from only the sparse source views.
4. Render the initial reconstruction from many held-out target camera poses. These renderings are the imperfect source samples `z0`.
5. Pair every imperfect rendering with the real held-out target image at the same pose. The real image is the target `z1`.
6. Store images, renderings, cameras, and point cloud in FlowR's expected layout.

Expected processed layout:

```text
scene/
  train/images/
  train/renders/
  test/images/
  test/renders/
  other/images/
  other/renders/
  train_cameras.json
  test_cameras.json
  pointcloud.ply
```

Why this matters: FlowR is not trained from arbitrary text prompts or random novel views. It learns a conditional transport from "what a sparse reconstruction renders" to "what the real dense capture would show". Without paired poses and ground-truth target images, you can run demos, but you cannot recreate the paper's training data.

## Synthetic Dataset Option

You can also create controlled datasets in Blender, Unreal, or another renderer:

1. Build or import a static 3D scene.
2. Render RGB images from known camera poses.
3. Export camera intrinsics/extrinsics.
4. Convert the result to Nerfstudio `transforms.json` or the FlowR layout above.
5. Make sparse/dense splits exactly like the real-data pipeline.

Synthetic data is good for debugging and controlled failure cases. It is weaker as a substitute for FlowR training because real captures contain camera noise, exposure changes, imperfect poses, reflective surfaces, and reconstruction artifacts that synthetic data often misses.

## Common Failure Modes

- COLMAP fails: add more overlap, remove blurry images, avoid repeated patterns, and keep camera movement smoother.
- Reconstruction floats or holes: use more source views and avoid unseen back sides in evaluation.
- Generated views are inconsistent: target poses may be too far from observed content.
- Metrics look bad but images look plausible: if evaluation views contain unseen content, there may be multiple plausible completions; PSNR/SSIM punish all but the exact ground truth.
- Full paper reproduction is expensive: training used 3.6M image pairs from 10.3k sequences, 64 H100 GPUs, and more than three days of aggregate fine-tuning time.
