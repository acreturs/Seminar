# FlowR Datasets

## Used In The Paper

| Dataset | Paper role | Local path convention | Access/size constraints |
| --- | --- | --- | --- |
| DL3DV-140 | Main sparse-view evaluation with 12 and 24 source views at 540x960 | `data/processed/flowr/dl3dv140-12v`, `data/processed/flowr/dl3dv140-24v` | Hugging Face access may be required. Full benchmark is about 2.1 TB; 960P-only is about 100-150 GB. |
| DL3DV-10K | FlowR training data source; the paper uses 6-36 sparse input views | `data/raw/dl3dv` | Very large: official 480P images+poses are about 730 GB; 960P is about 2.8 TB. |
| ScanNet++ | Dense-view evaluation on official `nvs_sem_val`; training source on `nvs_sem_train` | `data/raw/scannetpp`, `data/processed/flowr/scannetpp-val` | Official registration/login required. DSLR 2MP only is about 371 GB; default download is about 1.5 TB. |
| Nerfbusters | Dense-view evaluation with separate train/test trajectories | `data/raw/nerfbusters` | Data is linked from the Nerfbusters repo via Google Drive. |
| Mip-NeRF 360 | Appendix few-view comparison with 3, 6, and 9 views following ReconFusion | `data/raw/mipnerf360` | Public but large; keep outside git. |

## Prepared FlowR Dataset Layout

FlowR expects processed scenes shaped like this:

```text
scene/
  train/images/
  train/renders/
  test/images/
  test/renders/
  other/images/        # optional for eval; generated for Stage 2
  other/renders/       # optional
  train_cameras.json
  test_cameras.json
  pointcloud.ply
```

`scripts/activate_dataset.sh <path>` makes `data/active` point at the dataset or scene you are working with and writes `data/active_dataset.env`.

## Practical Defaults For This Workstation

This workspace currently has hundreds of GB free, not multiple TB. The safe default is:

1. Clone all code repos.
2. Download FlowR's small DL3DV scale-factor asset.
3. Use a small DL3DV subset or selected scenes for presentation examples.
4. Only download ScanNet++ after choosing an external disk or a smaller scene subset.
