"""Generate two point-cloud images spelling "TUM" in blue.

Both images show the same "TUM" text sampled as a point cloud:
  - sparse: few points -> barely recognizable
  - dense:  many points -> clearly readable

Purpose: illustrate the "sparse -> dense" idea for the FlowR talk.
Output: ../Bilder/tum_sparse.png and ../Bilder/tum_dense.png
"""

import os
import random

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.normpath(os.path.join(HERE, "..", "Bilder"))
os.makedirs(OUT_DIR, exist_ok=True)

# Canvas
W, H = 1600, 640
SUPERSAMPLE = 2  # render points at 2x then downscale for smooth anti-aliased dots

# Colors
BG = (245, 247, 250)          # light, neutral background
BLUE = (0, 86, 179)           # TUM-ish blue
BLUE_VARIANTS = [
    (0, 86, 179),
    (10, 102, 194),
    (0, 70, 150),
    (28, 117, 204),
]


def text_mask(text, w, h):
    """Render `text` and return the list of (x, y) pixel coords inside the glyphs."""
    img = Image.new("L", (w, h), 0)
    draw = ImageDraw.Draw(img)

    # Find a bold font and a size that fills the canvas width.
    font_candidates = [
        r"C:\Windows\Fonts\arialbd.ttf",
        r"C:\Windows\Fonts\seguisb.ttf",
        r"C:\Windows\Fonts\segoeuib.ttf",
        r"C:\Windows\Fonts\Arial.ttf",
    ]
    font_path = next((p for p in font_candidates if os.path.exists(p)), None)

    size = 10
    font = None
    while True:
        f = ImageFont.truetype(font_path, size) if font_path else ImageFont.load_default()
        bbox = draw.textbbox((0, 0), text, font=f)
        tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
        if tw > w * 0.82 or th > h * 0.7 or font_path is None:
            font = f if font_path else f
            break
        font = f
        size += 4

    bbox = draw.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = (w - tw) / 2 - bbox[0]
    y = (h - th) / 2 - bbox[1]
    draw.text((x, y), text, fill=255, font=font)

    px = img.load()
    coords = [(i, j) for j in range(h) for i in range(w) if px[i, j] > 128]
    return coords


def render_points(coords, n_points, dot_radius, jitter, seed, out_path):
    rng = random.Random(seed)
    canvas = Image.new("RGB", (W * SUPERSAMPLE, H * SUPERSAMPLE), BG)
    draw = ImageDraw.Draw(canvas)

    sample = [rng.choice(coords) for _ in range(n_points)]
    for (cx, cy) in sample:
        jx = rng.uniform(-jitter, jitter)
        jy = rng.uniform(-jitter, jitter)
        x = (cx + jx) * SUPERSAMPLE
        y = (cy + jy) * SUPERSAMPLE
        r = dot_radius * SUPERSAMPLE * rng.uniform(0.75, 1.25)
        color = rng.choice(BLUE_VARIANTS)
        draw.ellipse([x - r, y - r, x + r, y + r], fill=color)

    canvas = canvas.resize((W, H), Image.LANCZOS)
    canvas.save(out_path)
    print(f"wrote {out_path}  ({n_points} points)")


def main():
    coords = text_mask("TUM", W, H)
    if not coords:
        raise SystemExit("No glyph pixels found - font issue.")

    # Sparse: few, larger, jittery dots -> barely legible
    render_points(
        coords, n_points=550, dot_radius=3.2, jitter=6.0, seed=7,
        out_path=os.path.join(OUT_DIR, "tum_sparse.png"),
    )
    # Dense: many smaller dots -> clearly readable (same text)
    render_points(
        coords, n_points=14000, dot_radius=2.0, jitter=2.0, seed=7,
        out_path=os.path.join(OUT_DIR, "tum_dense.png"),
    )


if __name__ == "__main__":
    main()
