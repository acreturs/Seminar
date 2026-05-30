# Section 3 — Related Work (~5 min)

> Paper-konforme 3 Cluster (Section 5 des Papers).
> Zeitbudget: 5 min → 1 Folie pro Cluster (~1.5 min), 4. Folie als Einordnung von FlowR.
> Style-Check: "Cluster the papers, don't go one-by-one" ✅

---

## Slide 1 — Geometric Priors (~1.5 min)

**Cluster-Idee:** Klassiker für sparse-view NVS — Regularisierer und externe geometrische Cues kompensieren fehlende Views.

### Kurz: was ist 3DGS [25] (Kerbl, SIGGRAPH 2023)?
- Szene = Sammlung von 3D-Gaussians (Position, Skala, Rotation, Farbe, Opazität)
- Differenzierbarer Rasterizer → **Echtzeit-Rendering**
- State-of-the-art-Backbone für NVS — FlowR baut darauf auf

### Mip-NeRF 360 [2] (Barron, CVPR 2022)
- NeRF-Erweiterung für **unbounded scenes** (Außenaufnahmen, 360°)
- Non-lineare Szenen-Parametrisierung + Anti-Aliasing
- **Warum hier?** Klassiker, der gezeigt hat: NeRF-Qualität skaliert nicht naiv auf große Szenen — Regularisierung nötig
- ~2 230 Zitationen

### InstantSplat [17] (Fan, 2024)
- Sparse-view 3DGS **ohne SfM/COLMAP**
- Dichte Punktwolke aus MASt3R zur Initialisierung
- Trainiert in ~40 Sekunden
- **Warum hier?** FlowR's **direkter Vergleich/Baseline** im 12-/24-View-Setup → wichtig zu nennen, taucht später in Experiments auf

**Limitation des Clusters:** Regularisierer können nur das *bestrafen*, was vom Modell ohnehin schon vorgeschlagen wird — sie **erfinden keine fehlenden Inhalte**. In stark untersamplten Regionen → Floater, Löcher.

**Visual:** Logo/Thumbnail-Reihe der 3 Paper, ein kurzer Bullet je Paper.

---

## Slide 2 — Feed-forward Methods (~1.5 min)

**Cluster-Idee:** Netze, die Novel Views **direkt aus Input-Bildern predicten** — keine per-scene Optimierung mehr.

### PixelNeRF [66] (Yu, CVPR 2021)
- **Approach:** CNN encoded jedes Input-Bild → Features
- Pro Ray werden diese Features in den NeRF-MLP **conditioned** → Netz lernt szenen-unabhängige Priors
- Output: NeRF aus **1–3 Bildern**, ohne Re-Training
- "Grandfather" der generalizable NeRFs

### LRM [22] (Hong, ICLR 2024)
- **L**arge **R**econstruction **M**odel: Transformer mit **500 M Parametern**
- 1 Bild → 3D-NeRF in **5 Sekunden**
- Scale-up-Story: zeigt dass feed-forward 3D mit genug Daten / Parametern funktioniert
- ~534 Zitationen

**Limitation des Clusters:** Modelle sind nur so gut wie ihre Trainingsverteilung — out-of-distribution Views (z. B. weit weg von typischen Trajektorien) bleiben Problem.

**Visual:** PixelNeRF-Pipeline-Skizze (Input → CNN → Feature-Projection → MLP) + LRM Logo/Thumbnail.

---

## Slide 3 — Generative Priors (~1.5 min) ⭐ FlowR's Nachbarschaft

**Cluster-Idee:** 2D-Bild-/Video-Generative-Modelle als Prior — sie können fehlende Inhalte **halluzinieren** (im guten Sinn).

### ViewCrafter [67] (Yu, 2024)
- Video-Diffusion-Modell adaptiert für NVS
- Point-based Representation gibt grobe 3D-Hinweise → Video-Diffusion generiert die Frames mit Kamerakontrolle
- **Warum hier?** Direkter **Baseline-Vergleich** für FlowR (Tab. 1) → die Konkurrenz, die es zu schlagen gilt

### CAT3D [19] (Gao, NeurIPS 2024)
- **Multi-view** Diffusion: Input-Bilder + Target-Posen → konsistente Novel Views
- Danach Standard-3D-Rekonstruktion auf dem erweiterten View-Set
- **Konzeptionell der engste Verwandte:** gleiche Idee (extra Views generieren, dann refitten)
- ~230 Zitationen

**Limitation des Clusters (FlowR's Hebel!):**
- Diffusion startet von **reinem Noise** → kann existierende Geometrie nicht ausnutzen
- → halluziniert auch dort, wo die initiale Rekonstruktion schon korrekt ist
- → Inkonsistenz zwischen generierten Views

**Visual:** ViewCrafter + CAT3D Thumbnails, daneben ein Pfeil "Noise → Image" (Diffusion) vs. später FlowR "Rendering → Refined" als Teaser.

---

## Slide 4 (optional, kurz) — Wo sitzt FlowR?

Kleine 2×2-Matrix oder Venn-Diagramm:

| | Per-scene Optimierung | Feed-forward |
|---|---|---|
| **Regularisierung** | RegNeRF, SPARF | – |
| **Generative Prior** | CAT3D, ViewCrafter, **FlowR** | LRM, PixelNeRF |

FlowR's USP-Bullet:
> Start nicht aus **Noise**, sondern aus **Renderings der initialen Rekonstruktion** → Flow Matching statt Diffusion → schneller, konsistenter, weniger Halluzinationen.

→ Überleitung zur Method-Sektion.

---

## Open questions / TODO
- [ ] Thumbnails/Logos für die 6 Paper auswählen (von den Project-Pages)
- [ ] PixelNeRF-Pipeline neu zeichnen oder Screenshot? (Instructions empfehlen *neu zeichnen* — wäre für die Conditioning-Idee gut)
- [ ] Entscheiden ob Slide 4 (Einordnung) reinpasst oder ob das schon in die Method-Sektion gehört
