"""Dispara el Job de Bronze en Databricks y espera a que termine.

Usa la API REST de Jobs (run-now) para lanzar el notebook de Bronze desde
fuera de Databricks (por ejemplo, desde GitHub Actions tras la ingesta).
Hace polling del estado hasta que el run finaliza y falla si no fue exitoso.

Variables de entorno requeridas:
    DATABRICKS_HOST           https://dbc-xxxx.cloud.databricks.com
    DATABRICKS_TOKEN          token de acceso personal
    DATABRICKS_BRONZE_JOB_ID  id del job de Bronze

Uso:
    python -m ingestion.trigger_bronze
"""

from __future__ import annotations

import logging
import os
import sys
import time

import httpx
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s | %(levelname)s | %(message)s"
)
logger = logging.getLogger("trigger_bronze")

HOST = os.environ["DATABRICKS_HOST"].rstrip("/")
TOKEN = os.environ["DATABRICKS_TOKEN"]
JOB_ID = int(os.environ["DATABRICKS_BRONZE_JOB_ID"])

POLL_SECONDS = 15
TIMEOUT_MINUTES = 30

HEADERS = {"Authorization": f"Bearer {TOKEN}"}

# Estados terminales de un run en la API de Databricks Jobs.
TERMINAL_STATES = {"TERMINATED", "SKIPPED", "INTERNAL_ERROR"}


def trigger_run() -> int:
    """Lanza el job y devuelve el run_id."""
    response = httpx.post(
        f"{HOST}/api/2.1/jobs/run-now",
        headers=HEADERS,
        json={"job_id": JOB_ID},
        timeout=30.0,
    )
    response.raise_for_status()
    run_id = response.json()["run_id"]
    logger.info("Job %s lanzado, run_id=%s", JOB_ID, run_id)
    return run_id


def wait_for_run(run_id: int) -> None:
    """Hace polling del run hasta que termina; falla si no fue exitoso."""
    deadline = time.monotonic() + TIMEOUT_MINUTES * 60

    while True:
        if time.monotonic() > deadline:
            raise TimeoutError(f"El run {run_id} supero {TIMEOUT_MINUTES} min")

        response = httpx.get(
            f"{HOST}/api/2.1/jobs/runs/get",
            headers=HEADERS,
            params={"run_id": run_id},
            timeout=30.0,
        )
        response.raise_for_status()
        state = response.json()["state"]

        life_cycle = state["life_cycle_state"]
        logger.info("run %s: %s", run_id, life_cycle)

        if life_cycle in TERMINAL_STATES:
            result = state.get("result_state")
            if result == "SUCCESS":
                logger.info("Bronze completado con exito")
                return
            raise RuntimeError(f"Bronze fallo: life_cycle={life_cycle} result={result}")

        time.sleep(POLL_SECONDS)


def main() -> int:
    run_id = trigger_run()
    wait_for_run(run_id)
    return 0


if __name__ == "__main__":
    sys.exit(main())
