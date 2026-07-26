"""Cliente de IGDB v4 (API oficial, propiedad de Twitch/Amazon).

Autenticacion: OAuth2 client credentials contra id.twitch.tv.
Limite oficial: 4 requests por segundo.
Gratis para uso no comercial bajo el Twitch Developer Service Agreement.

Docs: https://api-docs.igdb.com/
"""

from __future__ import annotations

import logging
from datetime import datetime, timezone
from typing import Any, Iterator

import httpx

from .http_client import ApiClient

logger = logging.getLogger(__name__)

TWITCH_TOKEN_URL = "https://id.twitch.tv/oauth2/token"
IGDB_API = "https://api.igdb.com/v4"
IGDB_RATE_PER_SECOND = 3.0  # el limite es 4/s; dejamos margen
PAGE_SIZE = 500  # maximo permitido por IGDB


def get_app_access_token(client_id: str, client_secret: str) -> str:
    """Intercambia las credenciales de Twitch por un app access token."""
    response = httpx.post(
        TWITCH_TOKEN_URL,
        params={
            "client_id": client_id,
            "client_secret": client_secret,
            "grant_type": "client_credentials",
        },
        timeout=30.0,
    )
    response.raise_for_status()
    return response.json()["access_token"]


class IgdbClient:
    def __init__(self, client_id: str, client_secret: str, user_agent: str) -> None:
        token = get_app_access_token(client_id, client_secret)
        self._client = ApiClient(
            IGDB_API,
            IGDB_RATE_PER_SECOND,
            user_agent,
            headers={
                "Client-ID": client_id,
                "Authorization": f"Bearer {token}",
                "Accept": "application/json",
            },
        )

    def close(self) -> None:
        self._client.close()

    def query(self, endpoint: str, body: str) -> list[dict[str, Any]]:
        """IGDB usa su propio lenguaje (APIcalypse) en el body del POST."""
        result = self._client.post(f"/{endpoint}", content=body)
        return result if isinstance(result, list) else []

    def iter_games_by_steam_appids(
        self, appids: list[int], batch_size: int = 50
    ) -> Iterator[dict[str, Any]]:
        """Resuelve juegos de IGDB a partir de appids de Steam.

        Filtra por external_game_source = 1 (Steam). El campo `category`
        quedo obsoleto en external_games; este lo reemplaza.
        """
        ingested_at = datetime.now(timezone.utc).isoformat()

        for start in range(0, len(appids), batch_size):
            batch = appids[start : start + batch_size]
            uid_list = ",".join(f'"{appid}"' for appid in batch)
            body = (
                "fields uid, game.name, game.slug, game.first_release_date, "
                "game.total_rating, game.total_rating_count, game.genres.name, "
                "game.involved_companies.company.name, "
                "game.involved_companies.developer, "
                "game.involved_companies.publisher; "
                f"where external_game_source = 1 & uid = ({uid_list}); "
                f"limit {PAGE_SIZE};"
            )
            for row in self.query("external_games", body):
                game = row.get("game") or {}
                if not game:
                    continue
                companies = game.get("involved_companies", [])
                yield {
                    "steam_appid": int(row["uid"]),
                    "igdb_id": game.get("id"),
                    "name": game.get("name"),
                    "slug": game.get("slug"),
                    "first_release_date": game.get("first_release_date"),
                    "total_rating": game.get("total_rating"),
                    "total_rating_count": game.get("total_rating_count"),
                    "genres": [g["name"] for g in game.get("genres", [])],
                    "developers": [
                        c["company"]["name"]
                        for c in companies
                        if c.get("developer") and c.get("company")
                    ],
                    "publishers": [
                        c["company"]["name"]
                        for c in companies
                        if c.get("publisher") and c.get("company")
                    ],
                    "_ingested_at": ingested_at,
                }
