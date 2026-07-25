"""Punto de entrada de la ingesta (capa de extraccion).

Diseño:
  API oficial -> Parquet particionado por fecha/hora -> Volume de Unity Catalog

Se ejecuta FUERA de Databricks (en GitHub Actions) porque Databricks Free
Edition restringe el trafico saliente a un set limitado de dominios de confianza.

Uso:
    python -m ingestion.run_ingest player_counts
    python -m ingestion.run_ingest app_list
    python -m ingestion.run_ingest reviews
    python -m ingestion.run_ingest igdb_games
"""

from __future__ import annotations

import argparse
import io
import json
import logging
import os
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

import pyarrow as pa
import pyarrow.parquet as pq
from databricks.sdk import WorkspaceClient

from .igdb import IgdbClient
from .steam import SteamClient

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
)
logger = logging.getLogger("ingest")

ROOT = Path(__file__).resolve().parent.parent
WATCHLIST_PATH = ROOT / "ingestion" / "watchlist.json"

USER_AGENT = os.environ.get(
    "INGEST_USER_AGENT",
    "steam-lakehouse/1.0 (portfolio project; +https://github.com/tu-usuario/steam-lakehouse)",
)
CATALOG = os.environ.get("DATABRICKS_CATALOG", "steam_lakehouse")
SCHEMA = os.environ.get("DATABRICKS_LANDING_SCHEMA", "landing")
VOLUME = os.environ.get("DATABRICKS_VOLUME", "raw")


def load_watchlist() -> list[int]:
    """Lista curada de appids a monitorear cada hora.

    Traer los 200k apps del catalogo cada hora seria absurdo y abusivo.
    En un caso real esta lista se recalcularia semanalmente desde gold.
    """
    with WATCHLIST_PATH.open(encoding="utf-8") as handle:
        return [int(appid) for appid in json.load(handle)["appids"]]


def build_object_key(dataset: str, run_ts: datetime) -> str:
    """Layout Hive-style: permite pruning por particion en el lakehouse."""
    return (
        f"/Volumes/{CATALOG}/{SCHEMA}/{VOLUME}/{dataset}"
        f"/dt={run_ts:%Y-%m-%d}/hour={run_ts:%H}"
        f"/{dataset}_{run_ts:%Y%m%dT%H%M%S}_{uuid.uuid4().hex[:8]}.parquet"
    )


def write_and_upload(rows: Iterable[dict[str, Any]], dataset: str) -> str | None:
    """Materializa los registros en Parquet y los sube al Volume."""
    records = list(rows)
    if not records:
        logger.warning("Dataset '%s' no produjo registros, no se sube nada", dataset)
        return None

    run_ts = datetime.now(timezone.utc)
    table = pa.Table.from_pylist(records)

    buffer = io.BytesIO()
    pq.write_table(table, buffer, compression="snappy")
    buffer.seek(0)

    target = build_object_key(dataset, run_ts)
    workspace = WorkspaceClient()
    workspace.files.upload(target, buffer, overwrite=True)

    logger.info("Subidos %s registros a %s", len(records), target)
    return target


def ingest_player_counts() -> None:
    client = SteamClient(USER_AGENT)
    try:
        write_and_upload(
            client.iter_current_players(load_watchlist()), "steam_player_counts"
        )
    finally:
        client.close()


def ingest_app_list() -> None:
    client = SteamClient(USER_AGENT)
    try:
        write_and_upload(client.get_app_list(), "steam_app_list")
    finally:
        client.close()


def ingest_reviews() -> None:
    client = SteamClient(USER_AGENT)
    try:
        write_and_upload(
            client.iter_review_summaries(load_watchlist()), "steam_review_summary"
        )
    finally:
        client.close()


def ingest_igdb_games() -> None:
    client_id = os.environ["IGDB_CLIENT_ID"]
    client_secret = os.environ["IGDB_CLIENT_SECRET"]
    client = IgdbClient(client_id, client_secret, USER_AGENT)
    try:
        write_and_upload(
            client.iter_games_by_steam_appids(load_watchlist()), "igdb_games"
        )
    finally:
        client.close()


SOURCES = {
    "player_counts": ingest_player_counts,
    "app_list": ingest_app_list,
    "reviews": ingest_reviews,
    "igdb_games": ingest_igdb_games,
}


def main() -> int:
    parser = argparse.ArgumentParser(description="Ingesta de datos hacia el lakehouse")
    parser.add_argument("source", choices=sorted(SOURCES))
    args = parser.parse_args()

    logger.info("Iniciando ingesta de '%s'", args.source)
    SOURCES[args.source]()
    logger.info("Ingesta de '%s' finalizada", args.source)
    return 0


if __name__ == "__main__":
    sys.exit(main())
