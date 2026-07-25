"""DAG de orquestacion del lakehouse (Airflow 3.x).

Flujo:
    bronze (Auto Loader en Databricks) -> dbt build (silver + gold) -> validacion

La ingesta hacia el Volume la dispara GitHub Actions cada hora. Airflow se
encarga de lo que vive dentro de la plataforma: promover bronze, transformar
y validar.

Cosmos convierte cada modelo dbt en una task independiente de Airflow, con lo
cual el grafo del DAG muestra el linaje real y un fallo se aisla al modelo
que lo causo, no a "el paso de dbt".
"""

from __future__ import annotations

import os
from datetime import datetime, timedelta
from pathlib import Path

from airflow.sdk import Asset, dag, task
from airflow.providers.databricks.operators.databricks import (
    DatabricksSubmitRunOperator,
)
from cosmos import DbtTaskGroup, ProfileConfig, ProjectConfig, RenderConfig
from cosmos.profiles import DatabricksTokenProfileMapping

DBT_PROJECT_PATH = Path(os.environ["AIRFLOW_HOME"]) / "dags" / "dbt"
CATALOG = os.environ.get("DATABRICKS_CATALOG", "steam_lakehouse")

# Assets: Airflow 3 puede disparar DAGs cuando el dato cambia, no solo por reloj.
BRONZE_ASSET = Asset(f"databricks://{CATALOG}/bronze")
GOLD_ASSET = Asset(f"databricks://{CATALOG}/gold")

profile_config = ProfileConfig(
    profile_name="steam_lakehouse",
    target_name="prod",
    profile_mapping=DatabricksTokenProfileMapping(
        conn_id="databricks_default",
        profile_args={"catalog": CATALOG, "schema": "main"},
    ),
)

DEFAULT_ARGS = {
    "owner": "data-engineering",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "retry_exponential_backoff": True,
}


@dag(
    dag_id="steam_lakehouse",
    schedule="30 * * * *",  # 25 min despues de la ingesta horaria
    start_date=datetime(2026, 1, 1),
    catchup=False,
    max_active_runs=1,
    default_args=DEFAULT_ARGS,
    tags=["lakehouse", "steam", "medallion"],
    doc_md=__doc__,
)
def steam_lakehouse():

    load_bronze = DatabricksSubmitRunOperator(
        task_id="load_bronze",
        databricks_conn_id="databricks_default",
        outlets=[BRONZE_ASSET],
        tasks=[
            {
                "task_key": "bronze_autoloader",
                "notebook_task": {
                    "notebook_path": "/Workspace/Repos/steam-lakehouse/databricks/notebooks/01_bronze_autoloader",
                    "base_parameters": {"catalog": CATALOG},
                },
            }
        ],
    )

    transform = DbtTaskGroup(
        group_id="dbt",
        project_config=ProjectConfig(DBT_PROJECT_PATH),
        profile_config=profile_config,
        render_config=RenderConfig(select=["path:models"]),
        operator_args={"install_deps": True},
    )

    @task(outlets=[GOLD_ASSET])
    def check_freshness() -> dict[str, int]:
        """Control de cobertura: alerta si faltan horas en el ultimo dia.

        Un pipeline verde con huecos de datos es peor que uno rojo, porque
        nadie se entera. Este chequeo hace visible el hueco.
        """
        from airflow.providers.databricks.hooks.databricks_sql import (
            DatabricksSqlHook,
        )

        hook = DatabricksSqlHook(databricks_conn_id="databricks_default")
        rows = hook.get_first(
            f"""
            select
                count(distinct measured_at_hour) as horas_cargadas,
                count(distinct appid)            as juegos
            from {CATALOG}.gold.fct_player_activity_hourly
            where measured_at_hour >= current_timestamp() - interval 24 hours
            """
        )
        horas, juegos = int(rows[0]), int(rows[1])

        if horas < 20:
            raise ValueError(
                f"Solo {horas}/24 horas cargadas en el ultimo dia. Revisar la ingesta."
            )

        return {"horas_cargadas": horas, "juegos": juegos}

    load_bronze >> transform >> check_freshness()


steam_lakehouse()
