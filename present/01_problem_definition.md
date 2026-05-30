# Section 1 — Problem Definition (~2 min)

**Title slide:** *Flowing from sparse to dense 3D reconstruction*

---

## Slide 1 — Novel view synthesis works well with dense clouds

- Statement: Novel view synthesis is good when used with **dense** point clouds.
- **Figure:** image of a dense point cloud
- **Two examples** side-by-side:
  - NeRF
  - 3D Gaussian Splatting (3DGS)

> *Define briefly: what is a "novel view"?* — a rendered viewpoint that was **not** part of the input image set.

---

## Slide 2 — The problem: quality drops away from captured views

- When you move **away** from the original (training) camera positions, render quality degrades quickly.
- **Video / animation:** camera trajectory moving from a well-covered viewpoint into a position with no input photos → visible quality collapse.

---

## Slide 3 — FlowR's goal

- **FlowR** tackles this by **generating new views** that can be fed back into the model.
- Effect: turns a **sparse** 3D reconstruction into a **dense** one.
- **Animation:** sparse point cloud → progressively densifies into a dense one.

---

## Slide 4 — How? (build up gradually with arrows)

Reveal step-by-step on a single slide:

1. **Input:** posed source images + camera intrinsics/extrinsics + target camera pose
2. → **Initial** 3D Gaussian Splatting reconstruction
3. → **Flow model** outputs corrected / generated target images
4. → **Refined** Gaussian reconstruction on target views

Use **arrows** between the stages.

---

## Slide 5 (optional, separate) — Intuition for the flow model

- Like a standard Gaussian / diffusion-style model, **but**:
  - We do **not** start from pure noise.
  - We start from the **already existing (initial) reconstruction's renders**.
- → Flow model only has to *correct* / refine, not synthesize from scratch.

---

## Open questions / TODO
- [ ] Decide which NeRF + 3DGS example images to use (paper figures vs. re-rendered)
- [ ] Record / find the "moving away from captured view" degradation video
- [ ] Pick the sparse→dense densification animation source
- [ ] Confirm exact wording of inputs (posed source images vs. posed input images)
