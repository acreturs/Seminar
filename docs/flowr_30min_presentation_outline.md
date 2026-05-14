# FlowR 30-Minute Presentation Outline

Paper: "FlowR: Flowing from Sparse to Dense 3D Reconstructions"

Target: explain the problem, why existing methods fail, how FlowR changes the generative formulation, how it was trained/evaluated, and where the method is still weak.

## Timeline

| Time | Section | Goal |
| --- | --- | --- |
| 0:00-2:00 | Problem, input, output, definition | Establish the exact task and notation. |
| 2:00-5:00 | Why the problem matters and issues of existing methods | Motivate dense-view reconstruction and sparse-view pain points. |
| 5:00-10:00 | Related work | Position FlowR against geometry priors, feed-forward methods, and generative methods. |
| 10:00-18:00 | Key ideas of the proposed method and why it is better | Explain the initial reconstruction, conditional flow matching, multi-view generation, and refinement. |
| 18:00-25:00 | How the models were trained | Cover generated pair dataset, architecture, training schedule, benchmarks, and evaluation protocol. |
| 25:00-30:00 | Critical analysis | Discuss results, limitations, fairness, compute, and future work. |

## 0:00-2:00 Problem, Input, Output, Definition

Slide 1: title and one-sentence thesis.

FlowR addresses a gap in 3D reconstruction: NeRF/3DGS can be photorealistic with dense captures, but quality drops sharply when novel views move away from sparse input views. FlowR tries to make sparse or incomplete captures behave more like dense captures.

Slide 2: define the task.

- Input: posed source images `Isrc`, camera intrinsics/extrinsics, and target camera poses.
- Initial output: a 3D Gaussian Splatting reconstruction `Gsrc`.
- Flow model output: corrected/generated target images at chosen target poses.
- Final output: refined reconstruction `Gref` trained on original source images plus generated target views.
- Core definition: source distribution is not Gaussian noise. FlowR defines `p0(z|y)` as renderings from the imperfect initial reconstruction, and target distribution `p1(z|y)` as the real dense-capture images at the same poses.

Speaking line: "The key move is to generate from an already scene-consistent but imperfect rendering, not from pure noise."

## 2:00-5:00 Why The Problem Matters And Existing Issues

Slide 3: why dense 3D reconstruction matters.

- Applications: VR/AR scene capture, digital twins, telepresence, free-viewpoint video, inspection.
- Dense capture is expensive: many images, careful trajectories, controlled lighting, and lots of storage.
- Sparse casual captures are common, but underconstrained: unseen regions, weak geometry, floaters, blur, and disocclusion artifacts.

Slide 4: issues of existing methods.

- Plain 3DGS/Splatfacto: excellent with dense views, fragile under sparse or out-of-distribution views.
- Sparse-view reconstruction methods: can improve initialization, but still struggle when generated geometry or visibility is missing.
- Noise-to-image diffusion/view generation: may hallucinate inconsistent details because the model starts from noise and only conditions on a few views.
- Feed-forward methods: fast and learned, but often give up per-scene optimization quality.
- Dense-view methods like GANeRF improve realism, but do not directly solve sparse-to-dense data densification.

Transition: FlowR keeps per-scene optimization, but inserts a generative step that is anchored in the initial reconstruction.

## 5:00-10:00 Related Work

Use this section as a linked map. Give one sentence per cluster, then one example.

- NeRF: https://www.matthewtancik.com/nerf  
  Introduced neural radiance fields for high-quality novel view synthesis, but needs many posed views and slow per-scene optimization.
- 3D Gaussian Splatting: https://repo-sam.inria.fr/fungraph/3d-gaussian-splatting/  
  Real-time rendering with explicit Gaussian primitives; FlowR builds on this representation because it trains and renders quickly.
- Mip-NeRF 360: https://jonbarron.info/mipnerf360/  
  Important unbounded-scene benchmark and method; FlowR uses Mip-NeRF 360 in the appendix few-view comparison.
- Zip-NeRF: https://jonbarron.info/zipnerf/  
  Strong NeRF-style baseline for Mip-NeRF 360; appears in FlowR's appendix comparison.
- Nerfstudio/Splatfacto/Nerfacto: https://docs.nerf.studio/  
  Practical baseline framework; FlowR compares against Splatfacto and Nerfacto.
- Geometric priors such as RegNeRF, InfoNeRF, SparseNeRF, MonoSDF, FSGS:  
  These regularize sparse reconstruction with depth, entropy, normals, or geometry cues, but do not directly learn a dense-view correction distribution.
- MASt3R: https://github.com/naver/mast3r  
  FlowR uses strong multi-view matching/geometric cues to initialize reconstructions more robustly.
- PixelNeRF, IBRNet, MVSNeRF, pixelSplat, MVSplat, LRM, LGM:  
  Feed-forward or generalizable methods predict views or 3D representations directly; FlowR instead keeps per-scene optimization.
- InstantSplat: https://github.com/NVlabs/InstantSplat  
  Sparse-view Gaussian Splatting baseline; FlowR beats it on DL3DV-140, especially as views increase.
- ViewCrafter: https://github.com/Drexubery/ViewCrafter  
  Video-diffusion novel-view baseline; FlowR argues that generated views from such models may not improve reconstruction consistently.
- GANeRF: https://barbararoessle.github.io/ganerf/  
  Dense-view adversarial rendering baseline; FlowR compares against it on ScanNet++.
- Nerfbusters: https://github.com/ethanweber/nerfbusters  
  Benchmark and method for disjoint train/test trajectories; FlowR compares quality and coverage.
- ReconFusion: https://reconfusion.github.io/  
  Diffusion-prior 3D reconstruction; FlowR compares to it in the Mip-NeRF 360 appendix.
- CAT3D: https://cat3d.github.io/  
  Multi-view diffusion for creating 3D content; strong closed-source appendix comparator.
- ZeroNVS: https://kylesargent.github.io/zeronvs/  
  Zero-shot 360-degree novel view synthesis; used in the few-view Mip-NeRF 360 appendix.

Speaker framing: "Most prior generative work asks a diffusion model to invent novel views from noise. FlowR asks a flow model to correct renderings that already encode the scene geometry."

## 10:00-18:00 Key Ideas Of FlowR And Why It Is Better

Slide 8: pipeline overview.

1. Build a robust initial 3DGS reconstruction from sparse or dense inputs.
2. Select target camera poses for data densification.
3. Render the initial reconstruction at those poses.
4. Use a multi-view flow model to correct those renderings.
5. Train a refined 3DGS model with original and generated views.

Slide 9: robust initial reconstruction.

- Uses MASt3R-style dense matching/geometric estimates.
- Constructs a co-visibility graph to reduce unnecessary view pairs.
- Re-triangulates 3D points for cleaner initialization.
- Uses short 3DGS optimization with adaptive density control.
- Ablation message: dense initialization helps, but co-visibility plus re-triangulation keeps quality while reducing complexity.

Slide 10: the central formulation.

Standard diffusion/flow: `noise -> image`, conditioned on views.  
FlowR: `bad rendering from Gsrc -> real-looking target image`, conditioned on source views and cameras.

Why better:

- The source already contains scene layout, colors, and approximate geometry.
- If a rendering is already good, the model can learn to leave it nearly unchanged.
- Less pressure to hallucinate unsupported details.
- Corrected views remain more compatible with downstream 3DGS training.

Slide 11: multi-view model.

- Latent flow model with a VAE encoder/decoder.
- Diffusion Transformer backbone initialized from a large image model.
- Source and target views are tokenized together.
- Camera conditioning uses Plucker ray maps.
- Extra multi-view attention lets generated target images stay consistent with one another.

Slide 12: target-view generation and refinement.

- Ordered captures: sample target poses along a B-spline trajectory.
- Unordered images: sample candidate poses around reference views, filter bad poses with the initial reconstruction.
- Render target views from `Gsrc`, flow them to improved views, then train `Gref` on `Isrc union Itgt`.
- Different loss for generated target views: L2 plus SSIM plus LPIPS, because generated images can contain small VAE/generation artifacts.

Slide 13: results intuition.

- DL3DV-140: FlowR improves over Splatfacto, InstantSplat, and ViewCrafter in 12-view and 24-view sparse settings.
- ScanNet++: FlowR improves dense-view out-of-distribution views and beats GANeRF in the table.
- Nerfbusters: FlowR improves PSNR/SSIM while keeping strong coverage; opacity thresholding improves coverage comparison further.

## 18:00-25:00 How The Models Were Trained

Slide 14: generated training data.

- Training pairs come from 10.3k reconstructed sequences.
- Total: 3.6M rendered/ground-truth image pairs.
- Sources: DL3DV-10K and ScanNet++.
- DL3DV-10K: choose 6-36 equally spaced sparse input views, use 960P images, undistort, filter implausible scale factors.
- ScanNet++: use farthest-point/keyframe strategy, select 25-50% nearby training frames, undistort and resize to 640 x 960.

Slide 15: model architecture and scale.

- Base model: image-generation DiT-like model.
- Paper reports 2.7B base parameters, drops text conditioning, keeps 1.6B pre-initialized parameters.
- Final model: 1.75B parameters.
- Latent dimension: 16.
- 24 DiT blocks, 24 attention heads, head dimension 64, feed-forward hidden dimension 1536.
- FlashAttention2 for memory-efficient attention.

Slide 16: training schedule.

- Main training: 64 H100 GPUs, 125k steps, 48 hours.
- Batch size: 64, 12 views per batch element, 512px width with aspect ratio preserved.
- LR: cosine schedule, 1k warmup, max LR scaled with batch count.
- Fine-tuning: 960px width, 55k steps, 31 hours, 6 views per batch element, lower max LR.
- Flow inference uses 20 timesteps.

Slide 17: runtime and memory.

- Initial reconstruction: average 6.5 minutes per scene, roughly 6 minutes pointcloud initialization plus 30 seconds 3DGS.
- Flow generation: about 1.5 minutes for 200 additional images on one H100, processing up to 45 views at 540 x 960.
- Final reconstruction: average 42.4 minutes with longer 30k-step schedule and LPIPS loss.
- Memory ablation: 72 views needs about 42.3 GB; 12 views needs about 17.0 GB and remains competitive.

Slide 18: benchmarks and metrics.

- DL3DV-140: sparse-view evaluation with 12 and 24 source views at 540 x 960.
- ScanNet++: official validation split, official train/test split, 640 x 960.
- Nerfbusters: original disjoint train/test trajectory protocol.
- Appendix Mip-NeRF 360: 3, 6, and 9 view setting following ReconFusion.
- Metrics: PSNR, SSIM, LPIPS; Nerfbusters additionally reports coverage.

## 25:00-30:00 Critical Analysis

Slide 19: strengths.

- Strong conceptual shift: conditional rendering-to-image flow instead of noise-to-image generation.
- Better multi-view consistency than generating one image at a time.
- Works in sparse and dense settings.
- Good engineering: robust initialization plus generative densification plus refined optimization.
- Ablations support the main claims: source distribution matters, generated-view loss matters, and initialization choices matter.

Slide 20: limitations and risks.

- Very expensive training: 3.6M pairs, 64 H100 GPUs, large proprietary/pretrained model lineage.
- The paper model used a Meta-internal image generation model; the public repo is not exactly the same training setup.
- Depends on initial reconstruction quality. If content is completely unseen, FlowR explicitly does not hallucinate new content reliably.
- Static-scene assumption: dynamic objects remain a major problem.
- Camera selection uses heuristics; active view selection or uncertainty could improve it.
- Closed-source comparisons in the appendix, especially CAT3D and ReconFusion, limit reproducibility.
- Metrics can be misleading when test views include large unseen regions; multiple plausible completions may exist, but PSNR/SSIM reward only the recorded target.

Closing line: "FlowR is strongest when the scene is partially reconstructed but visually imperfect. It is not a magic scene completion model; it is a learned correction path from sparse-rendered evidence toward dense-capture appearance."
