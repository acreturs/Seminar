# Section 2 — Why it matters / Motivation (~3 min)

> Instruction-Check: 3 min total → ~3 Folien à 1 min.
> Muss zwei Fragen beantworten:
> (a) Why is this problem important?
> (b) What are the issues of existing methods?

---

## Slide 1 — Where you'd actually use this *(a) Importance / applications*

**Hook:** dense, frei-navigierbare 3D-Rekonstruktionen sind in vielen Branchen *das* Bottleneck.

- **Synthetic-Data-Pipelines** (z. B. **Levitum** — eigener Bezug!): mehr Trainingsdaten in höherer Qualität aus wenigen realen Captures
- VR / AR — freie Blickrichtung, immersive Räume
- Autonomous Driving / Robotics — fotorealistische Sim-Umgebungen
- E-Commerce / Real Estate — 3D-Ansichten aus wenigen Handyfotos

> **Sprecher-Notiz:** kurz mit dem Levitum-Bezug eröffnen → sofort persönliche Relevanz, macht die Folie konkret.

**Visual:** 3–4 Anwendungs-Icons / Thumbnails, kein Fließtext.

---

## Slide 2 — Real-world captures are *never* dense *(a) Importance, der echte Bottleneck)*

- **Echte Aufnahmen sind sparse** — niemand fotografiert 200 gleichmäßig verteilte Views; typische Handy-Captures sind unregelmäßig und unvollständig.
- **Gute dichte Datensätze sind teuer/selten** — Aufnahme-Aufwand wächst quadratisch mit Abdeckung.
- **Sparse → Dense = neue "Ground Truths" generieren** — aus wenigen realen Bildern viele plausibel-konsistente Views ableiten.
- **Demokratisierung:** wird billiger und vielseitiger einsetzbar (Nicht-Experten, mobile Geräte).

**Visual:** links sparse Kamera-Set (~10 Punkte), rechts dichtes Set (~200) — Pfeil dazwischen mit "$ + Zeit".

---

## Slide 3 — Why existing methods fall short *(b) Issues of existing methods*

Drei Failure Modes der bisherigen Ansätze:

**1. Noise-zu-Daten ist ein zu schweres Problem**
- Diffusion/Flow-Modelle starten typischerweise aus reinem Noise.
- Das ist ein *ill-defined* Problem → das Modell muss zu viel "erfinden".
- Folge: **Halluzinationen** und **Inkonsistenz zwischen Views**.

**2. Overfitting bei NeRF / 3DGS**
- Aktuelle Rekonstruktionen overfitten auf die Trainings-Views.
- Sehen super aus *an* den Trainings-Kameras — brechen weg, sobald man sich davon entfernt.

**3. View-Konsistenz vs. Schärfe-Tradeoff**
- Reine generative Priors (Diffusion) → schöne Einzelbilder, aber 3D-inkonsistent.
- Reine Regularisierung (Tiefe, Smoothness) → konsistent, aber unscharf / glatt.

→ **FlowR's Ansatz teasen:** "What if we *don't* start from noise, but from what the model already knows?"

**Visual:** drei kleine Vorher-/Nachher-Schnipsel oder Failure-Cases (z. B. Floater bei 3DGS, halluziniertes Detail bei Diffusion).

---

## Übergang zur nächsten Sektion

Letzter Satz auf Slide 3 sollte zur Related-Work-Sektion überleiten:
> *"Many works have tried to address these issues — let's group them into three families."*

---

## Open questions / TODO
- [ ] Welches Levitum-Beispiel konkret nennen? (Synthetic-Data-Use-Case, Quality-Improvement)
- [ ] Failure-Case-Bilder finden (Floater, Halluzinationen) — evtl. aus dem Paper selbst (Fig. 3 zeigt Splatfacto/InstantSplat Artefakte gut)
- [ ] Visualisierung "sparse vs. dense Kameraverteilung" — Manim?
- [ ] Anwendungs-Icons für Slide 1 wählen
