# FlowR Comparison Methods

This file tracks the methods that `2504.01647v2.pdf` uses in its main tables and appendix. The runnable public repos are listed in `configs/repos.yaml` and cloned by `scripts/clone_repos.sh`.

## Main Paper Tables

| Method | Where FlowR compares it | Repo/status | Notes |
| --- | --- | --- | --- |
| Splatfacto | DL3DV140, ScanNet++, Nerfbusters | `external/nerfstudio` | Nerfstudio's 3D Gaussian Splatting implementation. |
| Nerfacto | Nerfbusters | `external/nerfstudio` | Nerfstudio NeRF baseline. |
| InstantSplat | DL3DV140 sparse-view | `external/InstantSplat` | Open-source sparse-view GS baseline; FlowR uses GT poses for fairness. |
| ViewCrafter | DL3DV140 sparse-view | `external/ViewCrafter` | Open-source video diffusion NVS baseline; FlowR evaluates with GT poses and its refined reconstruction pipeline. |
| GANeRF | ScanNet++ dense-view | `external/ganerf` | Open-source adversarial NeRF/renderer baseline. |
| Nerfbusters | Nerfbusters benchmark | `external/nerfbusters` | Open-source method plus benchmark with disjoint train/eval trajectories. |

## Appendix / Additional Comparisons

| Method | Where FlowR compares it | Repo/status | Notes |
| --- | --- | --- | --- |
| Zip-NeRF | Mip-NeRF 360 few-view appendix | `external/camp_zipnerf` | CamP Zip-NeRF is the practical public release for Zip-NeRF-style runs. |
| ZeroNVS | Mip-NeRF 360 few-view appendix | `external/ZeroNVS` | Official ZeroNVS code. |
| ReconFusion | Mip-NeRF 360 few-view appendix | No public clone | The FlowR appendix describes this comparison as closed-source and uses provided splits. |
| CAT3D | Mip-NeRF 360 few-view appendix | No public clone | The FlowR appendix describes this comparison as closed-source and uses provided splits. |

## FlowR Itself

The official FlowR repository is `external/flowr`. Its README says `bash install.sh` creates a fresh `flowr` conda environment with CUDA Toolkit 12.2, GCC 12, pinned PyTorch/PyTorch3D/pycolmap, submodules, and a headless COLMAP build.

The code release notes that the original paper used a Meta-proprietary image generation model, while the public repo provides training and inference code for a Stable Diffusion 3 based FlowR variant.
