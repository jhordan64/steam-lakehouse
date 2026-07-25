# Databricks notebook source
# MAGIC %md
# MAGIC # Bronze — Auto Loader
# MAGIC
# MAGIC Lee incrementalmente los Parquet que la ingesta deja en el Volume y los
# MAGIC materializa en tablas Delta **bronze**, sin transformar el contenido.
# MAGIC
# MAGIC Reglas de la capa bronze:
# MAGIC - No se cambia ni se limpia el dato de origen.
# MAGIC - Se añade metadata de linaje: `_source_file`, `_loaded_at`.
# MAGIC - Es append-only: bronze es nuestro log inmutable y reproducible.
# MAGIC
# MAGIC `trigger(availableNow=True)` procesa todo lo pendiente y apaga el stream,
# MAGIC que es lo correcto para un job por lotes y lo mas barato en Free Edition.

# COMMAND ----------

from pyspark.sql import functions as F

dbutils.widgets.text("catalog", "steam_lakehouse")
dbutils.widgets.text("landing_schema", "landing")
dbutils.widgets.text("bronze_schema", "bronze")
dbutils.widgets.text("volume", "raw")

CATALOG = dbutils.widgets.get("catalog")
LANDING_SCHEMA = dbutils.widgets.get("landing_schema")
BRONZE_SCHEMA = dbutils.widgets.get("bronze_schema")
VOLUME = dbutils.widgets.get("volume")

VOLUME_ROOT = f"/Volumes/{CATALOG}/{LANDING_SCHEMA}/{VOLUME}"
CHECKPOINT_ROOT = f"{VOLUME_ROOT}/_checkpoints"

DATASETS = [
    "steam_player_counts",
    "steam_app_list",
    "steam_review_summary",
    "igdb_games",
]

# COMMAND ----------

spark.sql(f"CREATE SCHEMA IF NOT EXISTS {CATALOG}.{BRONZE_SCHEMA}")

# COMMAND ----------


def load_bronze(dataset: str) -> None:
    """Ingesta incremental de un dataset del Volume hacia su tabla bronze."""
    source_path = f"{VOLUME_ROOT}/{dataset}"
    target_table = f"{CATALOG}.{BRONZE_SCHEMA}.{dataset}"
    checkpoint = f"{CHECKPOINT_ROOT}/{dataset}"

    stream = (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", "parquet")
        .option("cloudFiles.schemaLocation", f"{checkpoint}/schema")
        # Si el origen añade una columna nueva, el stream se reinicia y la adopta
        # en vez de fallar en silencio.
        .option("cloudFiles.schemaEvolutionMode", "addNewColumns")
        .option("cloudFiles.partitionColumns", "dt, hour")
        .load(source_path)
        .withColumn("_source_file", F.col("_metadata.file_path"))
        .withColumn("_loaded_at", F.current_timestamp())
    )

    (
        stream.writeStream.option("checkpointLocation", f"{checkpoint}/state")
        .option("mergeSchema", "true")
        .trigger(availableNow=True)
        .toTable(target_table)
    )

    print(f"OK -> {target_table}")


for dataset_name in DATASETS:
    load_bronze(dataset_name)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Verificacion rapida

# COMMAND ----------

for dataset_name in DATASETS:
    table = f"{CATALOG}.{BRONZE_SCHEMA}.{dataset_name}"
    try:
        count = spark.table(table).count()
        print(f"{table}: {count:,} filas")
    except Exception as error:  # noqa: BLE001
        print(f"{table}: aun sin datos ({error})")
