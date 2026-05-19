# FlowR Seminar — Eigenes Zimmer in Google Colab

Dieses README führt dich **Schritt für Schritt** durch den ersten Lauf:
Du hast Fotos von einem **Zimmer**, willst sie in Google Colab hochladen
und am Ende ein 3D-Gaussian-Splatting-Modell im Browser drehen können.

Der ganze Rest (Paper-Datensätze, alle Vergleichsmethoden, ngrok-Tunnel)
ist hier bewusst **außen vor** — siehe `notebooks/start_colab.ipynb`
für die volle Pipeline.

---

## Repo-Struktur

```
.
├── notebooks/start_colab.ipynb     # Vollständige Pipeline
├── scripts/
│   ├── setup_colab.sh              # Installation + Repos klonen
│   ├── run_nerfstudio.sh           # ns-train Wrapper
│   └── tunnel.py                   # ngrok für den Viewer
├── configs/nerfstudio.yaml         # Methoden / Iterationen
├── data/                           # Bilder + COLMAP-Output (gitignored)
└── outputs/                        # Trainings-Resultate (gitignored)
```

---

## Voraussetzungen

- 20–80 Fotos vom Zimmer auf deinem Rechner (z.B. einmal langsam herumgegangen,
  starke Überlappung, scharf, möglichst konstante Belichtung).
- Ein Google-Konto für Colab.
- (Optional) Repo nach GitHub gepusht — falls nicht, kannst du es alternativ
  als ZIP in Colab hochladen.

---

## 1. Colab öffnen und GPU einschalten

1. Browser → <https://colab.research.google.com/>
2. **File → Open notebook → GitHub** (oder *Upload* falls noch nicht auf GitHub),
   und `notebooks/start_colab.ipynb` öffnen.
3. **Runtime → Change runtime type → GPU** (T4 reicht für Splatfacto).
4. Im Notebook **nur die ersten Zellen ausführen** wie unten beschrieben.

## 2. GPU prüfen (Notebook-Zelle 1)

```python
!nvidia-smi
```

Du solltest eine NVIDIA T4 (oder besser) sehen. Falls nicht → Runtime-Type neu setzen.

## 3. Repo holen (Notebook-Zelle 2)

Im zweiten Code-Block die Repo-URL anpassen, dann ausführen:

```python
REPO_URL = 'https://github.com/<DEIN_USER>/<DEIN_REPO>.git'
```

Falls dein Repo noch nicht auf GitHub liegt, ersetze diese Zelle durch:

```python
from google.colab import files
import zipfile, os
uploaded = files.upload()          # ZIP des Repos hochladen
name = next(iter(uploaded))
with zipfile.ZipFile(name) as z:
    z.extractall('/content')
%cd /content/<extrahierter-ordner>
```

## 4. Setup laufen lassen (~10 Minuten)

```python
!bash scripts/setup_colab.sh
```

Das installiert COLMAP, PyTorch (CUDA 12.1), tiny-cuda-nn und Nerfstudio
und klont die Vergleichs-Repos nach `external/`.
**Für den ersten Zimmer-Lauf brauchst du davon nur Nerfstudio** — der Rest
schadet aber nicht.

Wenn du es noch schneller willst, ohne die Repos zu klonen:

```python
!SKIP_HEAVY=1 bash scripts/setup_colab.sh
```

Am Ende sollte `ns-train --help` funktionieren:

```python
!ns-train --help | head
```

## 5. Zimmer-Fotos hochladen

```python
from google.colab import files
import os, shutil
os.makedirs('data/custom/images', exist_ok=True)
uploaded = files.upload()             # alle Fotos im Datei-Dialog auswählen
for name in uploaded:
    shutil.move(name, f'data/custom/images/{name}')
print(len(uploaded), 'Bilder im Pfad data/custom/images/')
```

Bei vielen Bildern lohnt der Umweg über Google Drive:

```python
from google.colab import drive
drive.mount('/content/drive')
!cp /content/drive/MyDrive/zimmer/*.jpg data/custom/images/
```

## 6. COLMAP-Posen berechnen (3–15 Minuten)

```bash
!ns-process-data images \
  --data data/custom/images \
  --output-dir data/custom/processed \
  --matching-method exhaustive
```

Wenn COLMAP keine Posen findet:
- mehr Bilder mit mehr Überlappung,
- `--matching-method sequential` falls die Reihenfolge sinnvoll ist,
- Bilder mit Bewegungsunschärfe aussortieren.

Erfolg = `data/custom/processed/transforms.json` existiert.

## 7. Modell trainieren (~15–30 Minuten auf T4)

```bash
!bash scripts/run_nerfstudio.sh splatfacto data/custom/processed 30000 outputs/custom/splatfacto
```

Argumente: `<methode> <daten> <iterationen> <output>`.
Für einen schnellen Smoke-Test: Iterationen auf `2000` runter.

## 8. Modell im Viewer drehen

Während `ns-train` läuft, druckt es die Viewer-URL. In Colab ist der lokale
Port nicht direkt erreichbar — deswegen über ngrok tunneln:

1. Token kostenlos holen: <https://dashboard.ngrok.com/get-started/your-authtoken>
2. In einer **neuen** Colab-Zelle:

```python
import os
os.environ['NGROK_AUTHTOKEN'] = 'DEIN_TOKEN_HIER'
from scripts.tunnel import open_tunnel
open_tunnel(port=7007)
```

Die ausgegebene `https://viewer.nerf.studio/?websocket_url=wss://...`-URL
im neuen Tab öffnen → das Zimmer ist da, du kannst mit Maus/WASD navigieren.

**Wichtig:** ngrok muss *während* das `ns-train` läuft offen sein.
Praktischer Ablauf in Colab:
- Eine Zelle startet das Training **im Hintergrund** mit `subprocess.Popen` (siehe Notebook Schritt 7).
- Direkt danach `open_tunnel(...)` in derselben Zelle.

## 9. Resultate sichern

Resultate liegen in `outputs/custom/splatfacto/<run-id>/`. Zip und Download:

```python
!zip -r zimmer.zip outputs/custom/splatfacto
from google.colab import files
files.download('zimmer.zip')
```

Oder direkt nach Drive kopieren, falls in Schritt 5 gemountet:

```bash
!cp -r outputs/custom/splatfacto /content/drive/MyDrive/zimmer-out/
```

---

## Häufige Stolpersteine

| Symptom | Ursache / Fix |
| --- | --- |
| `ns-train: command not found` | Schritt 4 (Setup) nicht (vollständig) gelaufen. Zelle erneut ausführen. |
| COLMAP scheitert / `transforms.json` fehlt | Zu wenige Bilder, zu wenig Überlappung, Bewegungsunschärfe. Mehr/bessere Fotos. |
| `CUDA out of memory` | `splatfacto-big` → `splatfacto`, oder Bildauflösung runter via `--downscale-factor 2` in `ns-process-data`. |
| Viewer-URL lädt nicht | Tunnel-Zelle vor Trainingsstart aufgerufen → erst Training starten, dann tunneln. Oder ngrok-Token leer. |
| Colab trennt die Runtime | Kostenlose Runtime hat ~12 h Limit. Trainings-Iterationen reduzieren oder Drive-Sync nutzen, damit nichts verloren geht. |

---

## Nächste Schritte (wenn das Zimmer steht)

- `splatfacto-big`, `nerfacto`, `instant-ngp` und `nerfbusters` mit demselben
  `run_nerfstudio.sh`-Aufruf vergleichen — nur die erste Spalte ändern.
- Das volle Notebook (`start_colab.ipynb` ab Schritt 4b) trainiert
  automatisch alle Nerfstudio-Methoden auf eigenen *und* Paper-Daten und
  legt sie nebeneinander in `outputs/`.
- Schwergewichtige Methoden (FlowR, ViewCrafter, …) liegen in `external/`
  bereit und werden per ihrer eigenen READMEs gestartet (FlowR braucht A100).
