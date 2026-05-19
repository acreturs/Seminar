"""Expose the Nerfstudio viewer websocket port from Colab via ngrok.

Usage from a Colab cell:

    from scripts.tunnel import open_tunnel
    public_url = open_tunnel(port=7007, token="<your_ngrok_token>")
    print(public_url)

The token is read from $NGROK_AUTHTOKEN if not passed explicitly. Get one at
https://dashboard.ngrok.com/get-started/your-authtoken — the free tier is
enough for a single seminar session.

`ns-train` listens on a websocket on the given port; ngrok must tunnel TCP
(or http with a websocket upgrade) for the viewer to connect. We use the
default http tunnel since Nerfstudio's viewer upgrades to ws over the same
hostname.
"""

from __future__ import annotations

import os
import sys
from typing import Optional


def open_tunnel(port: int = 7007, token: Optional[str] = None) -> str:
    """Start an ngrok tunnel to `localhost:port` and return the public URL."""
    try:
        from pyngrok import conf, ngrok
    except ImportError as exc:
        raise SystemExit(
            "pyngrok is not installed. Run: pip install pyngrok"
        ) from exc

    token = token or os.environ.get("NGROK_AUTHTOKEN")
    if not token:
        raise SystemExit(
            "No ngrok token. Pass token=... or set NGROK_AUTHTOKEN. "
            "Get a free one at https://dashboard.ngrok.com/get-started/your-authtoken"
        )

    conf.get_default().auth_token = token

    for tunnel in ngrok.get_tunnels():
        ngrok.disconnect(tunnel.public_url)

    public = ngrok.connect(port, "http", bind_tls=True)
    url = public.public_url
    viewer = (
        f"https://viewer.nerf.studio/?websocket_url={url.replace('https://', 'wss://')}"
    )
    print(f"[tunnel] ngrok    : {url}")
    print(f"[tunnel] viewer   : {viewer}")
    return viewer


def close_tunnels() -> None:
    from pyngrok import ngrok

    for tunnel in ngrok.get_tunnels():
        ngrok.disconnect(tunnel.public_url)
    ngrok.kill()


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 7007
    open_tunnel(port=port)
