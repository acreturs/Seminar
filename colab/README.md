# Room-to-3D + Difix3D — eigene 3D-Szene auf Colab Free erzeugen

End-to-End auf **Google Colab Free (T4)**: Handy-Video → COLMAP-Posen →
3D Gaussian Splatting (gsplat) → **Difix3D** Artefakt-Entfernung →
Before/After-Vergleich.

Notebook: [`room_to_3d.ipynb`](room_to_3d.ipynb)

```
https://colab.research.google.com/github/<USER>/<REPO>/blob/main/colab/room_to_3d.ipynb
```

---

## 1. Eigene Szene generieren — Schritt für Schritt

### 1.1 Video aufnehmen (entscheidet über Erfolg oder Rauschwolke!)

COLMAP rekonstruiert Kameraposen aus **Parallaxe** — also aus seitlicher
Bewegung, nicht aus Drehung. Daran ist der erste Versuch gescheitert
(Details in Abschnitt 6).

**So filmst du richtig:**

| ✅ Machen | ❌ Vermeiden |
|---|---|
| **Gehen**: langsam eine Runde / einen Bogen durch den Raum laufen | Auf der Stelle stehen und schwenken (Panorama-Stil) |
| 60–120 s Länge, Ende = Anfang (Loop Closure) | Schnelle Bewegungen → Motion Blur |
| Zwei Höhen abdecken (Augen- + Brusthöhe), Kamera leicht nach unten | Nur eine Höhe, Kamera horizontal starr |
| Texturreiche Bereiche im Bild (Möbel, Regale, Teppich) | Kahle weiße Wände, Spiegel, Fenster mit Gegenlicht |
| Gleichmäßiges Licht | Wechselnde Belichtung / Blitz |

### 1.2 Video nach Google Drive

Video in einen Drive-Ordner legen, z. B. `MyDrive/3DSeminar Bilder/Video Zimmer/`.
Es darf **genau ein** Video (mp4/mov/…) unterhalb dieses Ordners liegen.

### 1.3 Notebook öffnen

1. `room_to_3d.ipynb` in Colab öffnen (Link oben).
2. `Runtime → Change runtime type → T4 GPU`.

### 1.4 Konfigurieren (Schritt 2 im Notebook)

```python
DATA_SOURCE = 'video'        # eigene Szene
SEARCH_ROOT = '/content/drive/MyDrive/3DSeminar Bilder/Video Zimmer /'  # anpassen!
TARGET_FRAMES = 150          # 100–200 ist gut für die T4
```

`HF_TOKEN` brauchst du **nur** für den Testdaten-Modus (`dl3dv`, s. 1.8) —
dann eigenen Token eintragen oder besser als Colab-Secret `HF_TOKEN`
hinterlegen (Schlüssel-Icon links). **Nie mit eingetragenem Token pushen** —
bei public Repos revoked HuggingFace ihn automatisch.

### 1.5 Zellen von oben nach unten ausführen

| Schritt | Was passiert | Dauer (T4) | Worauf achten |
|---|---|---|---|
| 1–3 | GPU, Drive, Dependencies | 5–10 min | — |
| 3b | (nur `dl3dv`) Testszene laden | 5–10 min | skippt sich bei `video` |
| 4 | Frames + Schärfe-Filter + **Fingerprint** | 1–2 min | „X scharfe Frames" ≥ 100 |
| 5 | COLMAP (CPU) | 10–20 min | **„X/Y Bilder registriert"** — unter 80 % wird's mäßig, unter 50 % bricht die Zelle bewusst ab → Video neu aufnehmen |
| 5b | Undistortion → PINHOLE | 1 min | automatisch |
| 6 | Downscale-Bilder | 1 min | — |
| 7 | **Baseline-3DGS-Training** | 30–60 min | Heartbeat alle 60 s; Tab fokussiert lassen |
| **7b** | **Sanity-Check (PSNR)** | 1 min | **> 20 dB: gut · 16–20 dB: ok · < 16 dB: Stopp!** (s. Troubleshooting) |
| 8 | Flythrough-Video | — | erste visuelle Kontrolle |
| 8.5 | Cleaning + `.ply`-Export + **Vorschau** | 2 min | Erkennt man den Raum in der Vorschau, zeigt ihn auch jeder Viewer |
| 9 | Difix-Setup + Demo | 5–10 min | lädt das 5,2-GB-Modell `nvidia/difix` |
| **9b** | **Before/After auf deiner Szene** | 5–15 min | erzeugt `before_after_difix.mp4` |

Bricht die Session ab: einfach von oben neu durchlaufen — COLMAP kommt aus
dem Cache (an die Frame-Auswahl gekoppelt), fertige Schritte skippen sich.

### 1.6 Ergebnis interaktiv ansehen

`room.ply` aus `MyDrive/room3d/output_video/` **erst lokal herunterladen**, dann:

1. **[SuperSplat](https://playcanvas.com/supersplat/editor)** (empfohlen):
   Datei per Drag & Drop reinziehen, mit der Maus durch den Raum fliegen.
2. **[antimatter15-Viewer](https://antimatter15.com/splat/)**: PLY reinziehen.
3. **Lokal in diesem Repo**: [`splat-viewer/`](splat-viewer/) — vorher
   `python splat-viewer/convert.py room.ply -o room.splat`, dann
   `index.html` über einen lokalen Webserver öffnen.

### 1.7 Before/After fürs Seminar

Liegt nach Schritt 9b in `MyDrive/room3d/output_video/`:

- **`before_after_difix.mp4`** — Side-by-Side: links rohes 3DGS-Novel-View
  (mit Floatern/Schlieren), rechts dasselbe Frame nach Difix.
- **`before_after_frames/`** — drei `*_before.png`/`*_after.png`-Paare für Folien.

### 1.8 Alternative: Testdaten statt eigenem Video

- **`DATA_SOURCE='dl3dv'`** (empfohlen als Referenzlauf): lädt eine Szene aus
  dem [DL3DV-Benchmark](https://huggingface.co/datasets/DL3DV/DL3DV-Benchmark)
  mit fertigen COLMAP-Posen — exakt die Szene aus dem Difix3D-README-Beispiel.
  COLMAP entfällt komplett. Benötigt: kostenlosen HF-Account, Bedingungen auf
  der Dataset-Seite akzeptieren, [Token](https://huggingface.co/settings/tokens)
  eintragen (s. 1.4).
- **[Nerfbusters](https://github.com/ethanweber/nerfbusters)-Captures** (ohne
  Login): 12 Handy-Videos (zusammen 381 MB) — die Eval-Daten von Difix3D.
  Eines davon in Drive legen und wie ein eigenes Video durch die Pipeline
  schicken:
  ```bash
  git clone https://github.com/ethanweber/nerfbusters
  python nerfbusters/nerfbusters/download_nerfbusters_dataset.py captures
  ```

---

## 2. Kontext: FlowR vs. Difix3D+

Das Seminar-Paper ist **FlowR** (Fischer et al., arXiv:2504.01647, ICCV'25
Highlight): ein Flow-Matching-Modell, das fehlerhafte Novel-View-Renderings
einer spärlichen 3DGS-Rekonstruktion in Richtung „korrekt" verschiebt und
damit die Rekonstruktion verdichtet.

Es gibt seit 09/2025 ein offizielles Repo
([github.com/tobiasfshr/flowr](https://github.com/tobiasfshr/flowr)),
**aber keine veröffentlichten Modell-Gewichte**: Das Original-Modell war
Meta-proprietär; das Repo enthält nur Trainings-/Inferenz-Code für eine
SD3-basierte Variante, die man selbst trainieren müsste (3,6 M Bildpaare,
`accelerate --num_processes 8`, H100-Klasse). Autor in
[Issue #7](https://github.com/tobiasfshr/flowr/issues/7): *„we cannot provide
a trained model checkpoint due to licensing issues"*. Deshalb läuft der
praktische Teil mit **Difix3D+** (NVIDIA, CVPR 2025 Oral, arXiv:2503.01774),
das dasselbe Problem löst: Artefakte (Floater, Schlieren, Blur) in Novel
Views einer bestehenden Rekonstruktion entfernen und das Ergebnis ins
3D-Modell zurückdestillieren.

| | FlowR | Difix3D+ |
|---|---|---|
| Kernmodell | Flow Matching (multi-view, SD3-Basis) | Single-Step-Diffusion (SD-Turbo-Basis) |
| Code | [tobiasfshr/flowr](https://github.com/tobiasfshr/flowr) (Apache 2.0) | [nv-tlabs/Difix3D](https://github.com/nv-tlabs/Difix3D) |
| Gewichte | **keine** (Lizenz, Issue #7) | [HF `nvidia/difix`](https://huggingface.co/nvidia/difix) (~5,2 GB) |
| Input | posierte Bilder + initiales 3DGS (Stage 1 = `splatfacto-instant`) | posierte Bilder + 3DGS/NeRF-Checkpoint |
| Hardware | Inferenz: 45 Views @ 540×960 auf einer H100; Training: 8 GPUs | Inferenz läuft auf Colab T4 |

**Häufiges Missverständnis:** FlowR ist NICHT der „3DGS-Generator" vor Difix —
beide sind Stage-2-Refiner auf demselben Platz der Pipeline. Die initiale
3DGS-Rekonstruktion erzeugen beide mit Standard-Tools (FlowR:
nerfstudio/`splatfacto-instant`; wir: gsplat). „FlowR für Stufe 1 + Difix für
Stufe 2" würde zwei konkurrierende Verfahren stapeln — und an Stufe 1 nichts
ändern. Ohne FlowR-Gewichte bleibt ohnehin nur Difix3D lauffähig.

## 3. Was Difix3D+ ist — und was NICHT

**Difix3D+ ist KEINE eigenständige Video→3D-Pipeline.** Es setzt eine
existierende Rekonstruktion voraus. Der Gesamtworkflow ist immer:

```
Video ──ffmpeg──> Frames ──COLMAP──> Kameraposen ──gsplat──> Baseline-3DGS
                                                                │
                                              ┌─────────────────┤
                                              ▼                 ▼
                                     (b) Difix3D-Loop    (c) Difix als Post-
                                     progressives        processing auf jedem
                                     3D-Update           gerenderten Frame
```

Die drei Stufen aus dem Paper:

| Modus | Was passiert | im Notebook |
|---|---|---|
| **(a) Difix** | Einzelnes gerendertes Bild wird mit **einem** Diffusionsschritt (`timestep=199`, `guidance_scale=0`) gesäubert | Schritt 9 (Demo auf Repo-Beispielbildern) |
| **(b) Difix3D** | Während des 3DGS-Trainings werden regelmäßig Novel Views gerendert, von Difix gesäubert und als Pseudo-Ground-Truth zurückgespielt → die 3D-Repräsentation selbst wird besser | optionale Zelle (`RUN_DIFIX3D_TRAIN`) — auf T4 OOM-riskant, eher Colab Pro |
| **(c) Difix3D+** | Zusätzlich läuft Difix als Echtzeit-Postprocessing über jedes final gerenderte Frame | Schritt 9b — unser Before/After |

Repo-Bausteine (verifiziert): `src/inference_difix.py` (CLI für
Bild/Ordner/Video), `src/pipeline_difix.py` (`DifixPipeline`),
`examples/gsplat/simple_trainer_difix3d.py` (Modus (b), braucht `--ckpt` =
vortrainiertes Baseline-3DGS), `assets/example_input.png` (Sofort-Demo).

## 4. Welche Daten das Difix3D-Paper benutzt

**Training des Difix-Modells:**
- **DL3DV-10K**: 112 von 140 Benchmark-Szenen → **80 000 degraded↔clean
  Bildpaare**, erzeugt durch Sparse Reconstruction (jeden n-ten Frame
  weglassen), **Cycle Reconstruction** (NeRF auf verschobener Trajektorie),
  **Model Underfitting** (25–75 % der Trainingszeit) und Cross-Reference
  (Multi-Kamera).
- **RDS** (internes NVIDIA-Fahrszenen-Datenset): 40 Szenen, 100 000 Paare —
  nicht öffentlich.

**Evaluation:** 28 DL3DV-Hold-out-Szenen, **12 Nerfbusters-Captures**
(Handy-Videos — also genau unser Use-Case), 20 RDS-Szenen.

**Wichtig:** Das Difix-Modell ist generisch vortrainiert — wir trainieren
nichts nach, sondern nutzen die veröffentlichten Gewichte direkt auf unseren
eigenen Renderings.

## 5. Outputs in Drive

Pro Datenquelle ein eigener Ordner:

```
MyDrive/room3d/output_<video|dl3dv>/
  room.ply                    <- bereinigtes Modell: DAS in SuperSplat ziehen
  before_after_difix.mp4      <- Before/After Side-by-Side (Schritt 9b)
  before_after_frames/        <- Einzelbild-Paare für Folien
  gsplat_base/
    ckpts/ckpt_*.pt           <- Baseline-Checkpoints
    videos/                   <- Flythrough
    stats/                    <- Metriken (PSNR/SSIM/LPIPS)
  colmap_cache/<hash>/        <- Posen+Frames als konsistentes Paar (video-Modus)
  difix3d/ + room_difix3d.ply <- nur falls Modus (b) lief
```

## 6. Warum der erste Versuch „nichts" angezeigt hat (Post-Mortem)

Die alten Outputs (`room.ply` & Co. in diesem Ordner) wurden analysiert:

- **Das PLY-Format war korrekt** (292 k Gaussians, Opacities als Logits,
  Scales in Log-Space). Es lag NICHT an den Viewern und nicht an
  Orientierung/Zentrierung — deshalb änderten `room_centered.ply` /
  `room_yflip.ply` nichts.
- **Der Inhalt war strukturloses Rauschen**: Renderings aus jedem Blickwinkel
  (auch von innen) zeigen nur eine graue Blob-Wolke. Das „nichts" in
  SuperSplat war eine korrekt angezeigte Rauschwolke.
- **Wahrscheinlichste Ursache — Stale-Cache-Bug:** Schritt 4 wählte bei jedem
  Lauf andere Frames (Schärfe-Filter), Schritt 5 restaurierte aber alte
  COLMAP-Posen aus dem Drive-Cache. Gleiche Dateinamen, anderer Bildinhalt →
  jedes Bild wurde mit falscher Pose trainiert → Training konvergiert
  zwangsläufig zu Rauschen.
- Dazu: Trainingszelle lief mit `refine-stop-iter 4000` (die 8000er-Version
  steckte versehentlich in einer Markdown-Zelle), und es gab keine Checks.

**Fixes im aktuellen Notebook:** Hash-gekoppelter COLMAP-Cache (Bilder+Posen
als Paar), Registrierungs-Check (< 50 % → Abbruch), PSNR-Sanity-Gate
(Schritt 7b, < 16 dB → Abbruch), Export-Cleaning + In-Notebook-Vorschau,
Trainings-Zelle repariert.

## 7. Troubleshooting

| Problem | Fix |
|---|---|
| Schritt 7b: PSNR < 16 dB / Render = Rauschen | Posen passen nicht zu den Bildern → in Schritt 5 `FORCE_RECOMPUTE=True` setzen, neu rechnen. Bleibt es: Aufnahme-Protokoll prüfen (**Translation statt Rotation!**) |
| COLMAP: keine Rekonstruktion / < 50 % registriert | Zu wenig Overlap/Textur/Parallaxe → neu aufnehmen: langsam GEHEN, nicht schwenken |
| `CUDA out of memory` in Schritt 7 | `refine-stop-iter` auf 6000/4000, `DATA_FACTOR=8`, `TARGET_FRAMES=100` |
| `CUDA out of memory` in Schritt 9 | Runtime restarten, nur Schritte 1–3 + 9 laufen lassen; `NUM_NOVEL` senken |
| Colab disconnected | Tab fokussiert lassen; alles liegt in Drive, Zellen sind idempotent → von oben neu durchlaufen |
| Viewer zeigt nichts, obwohl Vorschau in 8.5 gut war | Datei vollständig heruntergeladen (Größe prüfen)? In SuperSplat Kamera-Reset/Frame nutzen |
| 401/403 beim DL3DV-Download | Bedingungen auf der Dataset-Seite nicht akzeptiert, Token fehlt/revoked → neuen Token erstellen |
| Import-Fehler nach Difix-Install | Difix pinnt alte diffusers/transformers → Runtime restarten; für reine 3DGS-Läufe `RUN_DIFIX=False` |
| Ergebnis verschwommen | `DATA_FACTOR=2`, mehr Frames, und/oder Difix3D (9b) |

## 8. Dateien in diesem Ordner

| Datei | Status |
|---|---|
| `room_to_3d.ipynb` | **die Pipeline** (aktuell) |
| `README.md` | dieses Dokument |
| `splat-viewer/` | lokaler WebGL-Viewer (antimatter15-Fork, lädt `room.splat`) |
| `room.ply`, `room.splat`, `room_centered.ply`, `room_fixed.ply`, `room_yflip.ply`, `room_check.png` | **Debug-Artefakte des fehlgeschlagenen ersten Laufs** (Rauschwolke, s. Abschnitt 6) — löschbar, sobald ein neuer Lauf durch ist |

## 9. Quellen

- Difix3D+: [arXiv:2503.01774](https://arxiv.org/abs/2503.01774) ·
  [Code](https://github.com/nv-tlabs/Difix3D) ·
  [Gewichte](https://huggingface.co/nvidia/difix)
- FlowR: [arXiv:2504.01647](https://arxiv.org/abs/2504.01647) ·
  [Code (ohne Gewichte)](https://github.com/tobiasfshr/flowr)
- DL3DV-Benchmark: [HuggingFace](https://huggingface.co/datasets/DL3DV/DL3DV-Benchmark)
- Nerfbusters: [arXiv:2304.10532](https://arxiv.org/abs/2304.10532) ·
  [Code + Daten](https://github.com/ethanweber/nerfbusters)
- gsplat: [github.com/nerfstudio-project/gsplat](https://github.com/nerfstudio-project/gsplat)
