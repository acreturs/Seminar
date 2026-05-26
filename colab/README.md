# Room-to-3D Colab Notebook

End-to-End-Pipeline auf **Google Colab Free (T4)**: Video deines Zimmers -> 3D Gaussian Splatting Modell -> (optional) Difix3D Verfeinerung -> Flythrough-Video.

## Schnellstart

1. Repo zu GitHub pushen (siehe unten) und `room_to_3d.ipynb` ueber den **"Open in Colab"** Knopf oeffnen — oder direkt:

   ```
   https://colab.research.google.com/github/<USER>/<REPO>/blob/main/colab/room_to_3d.ipynb
   ```

2. In Colab: `Runtime` -> `Change runtime type` -> **T4 GPU**.

3. Video aufnehmen (Handy):
   - 30-60s, **langsam** durch den Raum
   - mehrere Hoehen, kein Schwenk, kein Spiegel/grelles Fenster
   - der Raum sollte Textur haben (rein weisse Waende = COLMAP scheitert)

4. Video in Google Drive ablegen unter `MyDrive/room3d/room.mp4`.

5. Notebook von oben nach unten durchlaufen. Erwartete Laufzeit ~1-2h fuer Baseline, +1h fuer optionalen Difix3D-Schritt.

## Was passiert

| Schritt | Tool | Dauer T4 |
|---|---|---|
| Frames extrahieren | ffmpeg | <1 Min |
| Kameraposen schaetzen | COLMAP (CPU) | 10-20 Min |
| Baseline 3DGS trainieren | gsplat | 30-60 Min |
| (Optional) Verfeinerung | Difix3D | 60-90 Min |

## Outputs

Alles persistent in Drive unter `MyDrive/room3d/output/`:
- `gsplat_base/ckpts/ckpt_*.pt` — das trainierte Modell
- `gsplat_base/videos/*.mp4` — Flythrough
- `difix3d/...` — falls Schritt 9 lief

Die `.pt` / `.ply` Files kannst du lokal in [gsplat](https://github.com/nerfstudio-project/gsplat) oder [SuperSplat](https://playcanvas.com/supersplat/editor) interaktiv anschauen.

## Limits Colab Free

- **VRAM:** T4 hat 16 GB. Difix3D + 3DGS gleichzeitig ist knapp — `DATA_FACTOR=8` und weniger Frames falls OOM.
- **Session:** ~12h aktiv, ~90 Min idle. Tab fokussiert lassen.
- **Disk:** `/content` ist ephemer, deswegen alles direkt in Drive schreiben (macht das Notebook automatisch).
