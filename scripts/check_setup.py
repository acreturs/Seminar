#!/usr/bin/env python3
from __future__ import annotations

import shutil
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def status(label: str, ok: bool, detail: str = "") -> None:
    mark = "OK" if ok else "MISSING"
    suffix = f" - {detail}" if detail else ""
    print(f"{mark:7} {label}{suffix}")


def main() -> None:
    print(f"Project root: {ROOT}")
    local_bins = {
        "conda": ROOT / ".conda" / "bin" / "conda",
        "huggingface-cli": ROOT / ".conda" / "envs" / "flowr-lab" / "bin" / "huggingface-cli",
    }
    for cmd in ["git", "wget", "unzip", "conda", "huggingface-cli", "ns-process-data", "ns-train"]:
        path = shutil.which(cmd)
        if not path and cmd in local_bins and local_bins[cmd].exists():
            path = str(local_bins[cmd])
        status(f"command:{cmd}", bool(path), path or "")

    for rel in [
        "external/flowr",
        "external/nerfstudio",
        "external/InstantSplat",
        "external/ViewCrafter",
        "external/ganerf",
        "external/nerfbusters",
        "data/assets/dl3dv_scales",
        "data/active",
    ]:
        p = ROOT / rel
        status(rel, p.exists(), str(p.resolve()) if p.exists() else "")


if __name__ == "__main__":
    main()
