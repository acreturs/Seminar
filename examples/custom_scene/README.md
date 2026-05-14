# Custom Scene Images

Place your own overlapping scene photos in `examples/custom_scene/images/`.

Recommended capture pattern:

- 20-80 sharp images for a reliable first test.
- Move around the object/room with strong overlap between neighboring views.
- Avoid motion blur, large moving objects, mirrors, and exposure changes for the first run.

Then run:

```bash
conda activate flowr
bash scripts/process_custom_images.sh examples/custom_scene/images my_scene
bash scripts/run_flowr_stage1.sh data/processed/custom/my_scene
```
