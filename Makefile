.PHONY: install lint test ingest-hourly ingest-daily dbt-build dbt-docs

install:
	python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt

lint:
	ruff check ingestion/
	ruff format --check ingestion/
	cd dbt && sqlfluff lint models/

test:
	pytest tests/ -v

ingest-hourly:
	python -m ingestion.run_ingest player_counts

ingest-daily:
	python -m ingestion.run_ingest app_list
	python -m ingestion.run_ingest reviews
	python -m ingestion.run_ingest igdb_games

dbt-build:
	cd dbt && dbt deps && dbt build

dbt-docs:
	cd dbt && dbt docs generate --static
