"""Cliente HTTP compartido: rate limiting + reintentos con backoff.

Las APIs oficiales de Steam e IGDB castigan el trafico agresivo (Valve llega a
aplicar shadow-bans). Todo request del proyecto pasa por aqui para garantizar
que nunca superamos el limite pactado.
"""

from __future__ import annotations

import logging
import threading
import time
from dataclasses import dataclass
from typing import Any

import httpx
from tenacity import (
    before_sleep_log,
    retry,
    retry_if_exception_type,
    stop_after_attempt,
    wait_exponential,
)

logger = logging.getLogger(__name__)

RETRYABLE_STATUS = {429, 500, 502, 503, 504}


class RetryableHTTPError(Exception):
    """Error que sí vale la pena reintentar (429 / 5xx)."""


@dataclass
class RateLimiter:
    """Token bucket minimalista y thread-safe.

    Args:
        rate_per_second: cuantos requests por segundo se permiten como maximo.
    """

    rate_per_second: float

    def __post_init__(self) -> None:
        self._min_interval = 1.0 / self.rate_per_second
        self._lock = threading.Lock()
        self._last_call = 0.0

    def acquire(self) -> None:
        with self._lock:
            elapsed = time.monotonic() - self._last_call
            wait_for = self._min_interval - elapsed
            if wait_for > 0:
                time.sleep(wait_for)
            self._last_call = time.monotonic()


class ApiClient:
    """Wrapper de httpx con rate limiting, reintentos y User-Agent identificable.

    Identificarse con un User-Agent real es una cortesia basica y reduce
    muchisimo la probabilidad de que te bloqueen.
    """

    def __init__(
        self,
        base_url: str,
        rate_per_second: float,
        user_agent: str,
        timeout: float = 30.0,
        headers: dict[str, str] | None = None,
    ) -> None:
        self._limiter = RateLimiter(rate_per_second)
        self._client = httpx.Client(
            base_url=base_url,
            timeout=timeout,
            headers={"User-Agent": user_agent, **(headers or {})},
            follow_redirects=True,
        )

    def __enter__(self) -> "ApiClient":
        return self

    def __exit__(self, *exc_info: object) -> None:
        self.close()

    def close(self) -> None:
        self._client.close()

    @retry(
        retry=retry_if_exception_type((RetryableHTTPError, httpx.TransportError)),
        wait=wait_exponential(multiplier=2, min=2, max=120),
        stop=stop_after_attempt(5),
        before_sleep=before_sleep_log(logger, logging.WARNING),
        reraise=True,
    )
    def request(self, method: str, url: str, **kwargs: Any) -> dict[str, Any]:
        self._limiter.acquire()
        response = self._client.request(method, url, **kwargs)

        if response.status_code in RETRYABLE_STATUS:
            raise RetryableHTTPError(
                f"{method} {url} -> {response.status_code}"
            )

        response.raise_for_status()

        if not response.content:
            return {}
        return response.json()

    def get(self, url: str, **kwargs: Any) -> dict[str, Any]:
        return self.request("GET", url, **kwargs)

    def post(self, url: str, **kwargs: Any) -> dict[str, Any]:
        return self.request("POST", url, **kwargs)
