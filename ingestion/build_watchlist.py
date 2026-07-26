"""Genera la watchlist combinando dos fuentes:

1. Top 100 mas jugados de Steam (ISteamChartsService/GetMostPlayedGames).
2. Catalogo de juegos de empresas famosas en Steam (via IGDB).

La union se deduplica. Asi el dashboard tiene tanto los juegos calientes del
momento como el catalogo completo de estudios reconocidos.

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
from .igdb import IgdbClient

load_dotenv()

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s | %(levelname)s | %(message)s"
)
logger = logging.getLogger("build_watchlist")

WATCHLIST_PATH = Path(__file__).resolve().parent / "watchlist.json"
USER_AGENT = os.environ.get("INGEST_USER_AGENT", "steam-lakehouse/1.0")

# IDs de empresas en IGDB (matriz o estudio principal), confirmados por diagnostico.
# Se busca como developer O publisher para captar tanto lo que hacen como lo que editan.
COMPANIES = {
    "Capcom": 37,
    "Valve": 56,
    "Rockstar Games": 29,
    "Ubisoft Entertainment": 104,
    "FromSoftware": 1012,
    "Electronic Arts": 1,
    "Activision": 66,
    "Ryu Ga Gotoku": 19080,
    "Atlus": 818,
}

# Cuantos juegos como maximo traer por empresa (evita catalogos gigantes).
MAX_GAMES_PER_COMPANY = 100


def get_top_played() -> list[int]:
    """Top 100 mas jugados desde el endpoint oficial de charts de Steam."""
    client = ApiClient("https://api.steampowered.com", 1.0, USER_AGENT)
    try:
        payload = client.get("/ISteamChartsService/GetMostPlayedGames/v1/")
    finally:
        client.close()

    ranks = payload.get("response", {}).get("ranks", [])
    appids = [entry["appid"] for entry in ranks if "appid" in entry]
    logger.info("Top jugados: %s appids", len(appids))
    return appids


def get_company_appids(igdb: IgdbClient) -> list[int]:
    """Appids de Steam de los juegos de cada empresa famosa."""
    appids: list[int] = []

    for nombre, company_id in COMPANIES.items():
        body = (
            "fields game.external_games.uid, "
            "game.external_games.external_game_source; "
            f"where (developer = true | publisher = true) & company = {company_id} "
            "& game.external_games.external_game_source = 1; "
            f"limit {MAX_GAMES_PER_COMPANY};"
        )
        rows = igdb.query("involved_companies", body)

        encontrados = 0
        for row in rows:
            game = row.get("game") or {}
            for ext in game.get("external_games", []):
                # external_game_source = 1 es Steam
                if ext.get("external_game_source") == 1 and ext.get("uid"):
                    try:
                        appids.append(int(ext["uid"]))
                        encontrados += 1
                    except (ValueError, TypeError):
                        continue

        logger.info("%s (id=%s): %s appids", nombre, company_id, encontrados)

    return appids


def build_watchlist() -> list[int]:
    """Combina top jugados + juegos de empresas, deduplicado."""
    top = get_top_played()

    igdb = IgdbClient(
        os.environ["IGDB_CLIENT_ID"],
        os.environ["IGDB_CLIENT_SECRET"],
        USER_AGENT,
    )
    try:
        company_games = get_company_appids(igdb)
    finally:
        igdb.close()

    # Union sin duplicados, manteniendo orden (top primero).
    combinado = list(dict.fromkeys(top + company_games))
    logger.info(
        "Watchlist combinada: %s del top + %s de empresas = %s unicos",
        len(top),
        len(company_games),
        len(combinado),
    )
    return combinado


def main() -> None:
    appids = build_watchlist()

    data = {
        "_comment": (
            "Watchlist generada por build_watchlist.py: top 100 mas jugados "
            "(ISteamChartsService) + catalogo de empresas famosas (IGDB)."
        ),
        "appids": appids,
    }

    with WATCHLIST_PATH.open("w", encoding="utf-8") as handle:
        json.dump(data, handle, indent=2)

    logger.info("Watchlist guardada: %s juegos en %s", len(appids), WATCHLIST_PATH)


if __name__ == "__main__":
    main()