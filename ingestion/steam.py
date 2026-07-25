"""Cliente de la Steam Web API (oficial de Valve).

Endpoints usados (todos publicos, sin API key):
  - ISteamApps/GetAppList/v2       -> catalogo completo (dimension)
  - ISteamUserStats/GetNumberOfCurrentPlayers/v1 -> jugadores concurrentes (hecho)
  - store/appreviews/{appid}       -> resumen de reseñas (documentado en Steamworks)

Docs: https://partner.steamgames.com/doc/webapi_overview
"""

from __future__ import annotations

import logging
from datetime import datetime, timezone
from typing import Any, Iterable, Iterator

from .http_client import ApiClient

logger = logging.getLogger(__name__)

WEB_API = "https://api.steampowered.com"
STORE_API = "https://store.steampowered.com"

# Valve no publica un limite oficial. 1 req/s es conservador y seguro.
STEAM_RATE_PER_SECOND = 1.0


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


class SteamClient:
    def __init__(self, user_agent: str) -> None:
        self._web = ApiClient(WEB_API, STEAM_RATE_PER_SECOND, user_agent)
        self._store = ApiClient(STORE_API, STEAM_RATE_PER_SECOND, user_agent)

    def close(self) -> None:
        self._web.close()
        self._store.close()

    def get_app_list(self) -> list[dict[str, Any]]:
        """Catalogo completo de apps. ~200k filas, incluye DLC y soundtracks.

        Se ingesta una vez al dia, no cada hora.
        """
        payload = self._web.get("/ISteamApps/GetAppList/v2/")
        apps = payload.get("applist", {}).get("apps", [])
        logger.info("GetAppList devolvio %s apps", len(apps))
        ingested_at = _now()
        return [
            {"appid": app["appid"], "name": app.get("name"), "_ingested_at": ingested_at}
            for app in apps
        ]

    def get_current_players(self, appid: int) -> dict[str, Any]:
        """Jugadores concurrentes de un juego en este instante."""
        payload = self._web.get(
            "/ISteamUserStats/GetNumberOfCurrentPlayers/v1/",
            params={"appid": appid},
        )
        response = payload.get("response", {})
        return {
            "appid": appid,
            "player_count": response.get("player_count"),
            "result": response.get("result"),
            "_ingested_at": _now(),
        }

    def iter_current_players(self, appids: Iterable[int]) -> Iterator[dict[str, Any]]:
        """Recorre la watchlist. Un fallo puntual no debe tumbar la corrida."""
        for appid in appids:
            try:
                yield self.get_current_players(appid)
            except Exception:  # noqa: BLE001 - queremos continuar con el resto
                logger.exception("Fallo player_count para appid=%s", appid)

    def get_review_summary(self, appid: int) -> dict[str, Any]:
        """Resumen agregado de reseñas (no el texto completo).

        num_per_page=0 pide solo el query_summary, que es lo que necesitamos
        para metricas y evita descargar miles de reseñas cada hora.
        """
        payload = self._store.get(
            f"/appreviews/{appid}",
            params={
                "json": 1,
                "language": "all",
                "purchase_type": "all",
                "num_per_page": 0,
            },
        )
        summary = payload.get("query_summary", {})
        return {
            "appid": appid,
            "review_score": summary.get("review_score"),
            "review_score_desc": summary.get("review_score_desc"),
            "total_positive": summary.get("total_positive"),
            "total_negative": summary.get("total_negative"),
            "total_reviews": summary.get("total_reviews"),
            "_ingested_at": _now(),
        }

    def iter_review_summaries(self, appids: Iterable[int]) -> Iterator[dict[str, Any]]:
        for appid in appids:
            try:
                yield self.get_review_summary(appid)
            except Exception:  # noqa: BLE001
                logger.exception("Fallo review_summary para appid=%s", appid)
