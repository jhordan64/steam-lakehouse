"""Genera la watchlist con el top 100 de juegos mas jugados de Steam.

Usa el endpoint oficial ISteamChartsService/GetMostPlayedGames, que devuelve
el ranking semanal de Valve (100 entradas: appid, rank, pico de jugadores).
Los nombres no vienen aqui; se resuelven despues via IGDB.

Uso:
    python -m ingestion.build_watchlist
"""

from __future__ import annotations

import json
import logging
import os
from pathlib import Path

from dotenv import load_dotenv

from .http_client import ApiClient

load_dotenv()

logging.basicConfig(level=logging.INFO, format="%(asctime)s | %(levelname)s | %(message)s")
logger = logging.getLogger("build_watchlist")

WATCHLIST_PATH = Path(__file__).resolve().parent / "watchlist.json"
USER_AGENT = os.environ.get("INGEST_USER_AGENT", "steam-lakehouse/1.0")


def build_watchlist() -> list[int]:
    """Consulta el top 100 mas jugado y devuelve la lista de appids."""
    client = ApiClient("https://api.steampowered.com", 1.0, USER_AGENT)
    try:
        payload = client.get("/ISteamChartsService/GetMostPlayedGames/v1/")
    finally:
        client.close()

    ranks = payload.get("response", {}).get("ranks", [])
    appids = [entry["appid"] for entry in ranks if "appid" in entry]
    logger.info("Top juegos obtenidos: %s appids", len(appids))
    return appids


def main() -> None:
    appids = build_watchlist()

    data = {
        "_comment": (
            "Top juegos mas jugados de Steam, generado automaticamente por "
            "build_watchlist.py desde ISteamChartsService/GetMostPlayedGames."
        ),
        "appids": appids,
    }

    with WATCHLIST_PATH.open("w", encoding="utf-8") as handle:
        json.dump(data, handle, indent=2)

    logger.info("Watchlist actualizada: %s juegos en %s", len(appids), WATCHLIST_PATH)


if __name__ == "__main__":
    main()