create or replace view `steam_lakehouse`.`dbt_dev`.`dbt_artifacts_hashes`
  
  
  
  as
    




select
  'dbt_models' as artifacts_model,
   metadata_hash
from `steam_lakehouse`.`dbt_dev`.`dbt_models`
 union all 

select
  'dbt_tests' as artifacts_model,
   metadata_hash
from `steam_lakehouse`.`dbt_dev`.`dbt_tests`
 union all 

select
  'dbt_sources' as artifacts_model,
   metadata_hash
from `steam_lakehouse`.`dbt_dev`.`dbt_sources`
 union all 

select
  'dbt_snapshots' as artifacts_model,
   metadata_hash
from `steam_lakehouse`.`dbt_dev`.`dbt_snapshots`
 union all 

select
  'dbt_metrics' as artifacts_model,
   metadata_hash
from `steam_lakehouse`.`dbt_dev`.`dbt_metrics`
 union all 

select
  'dbt_exposures' as artifacts_model,
   metadata_hash
from `steam_lakehouse`.`dbt_dev`.`dbt_exposures`
 union all 

select
  'dbt_seeds' as artifacts_model,
   metadata_hash
from `steam_lakehouse`.`dbt_dev`.`dbt_seeds`
 union all 

select
  'dbt_columns' as artifacts_model,
   metadata_hash
from `steam_lakehouse`.`dbt_dev`.`dbt_columns`


order by metadata_hash
