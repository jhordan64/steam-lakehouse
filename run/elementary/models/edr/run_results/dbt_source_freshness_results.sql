-- back compat for old kwarg name
  
  
  
  
  
  
      
          
          
      
  

    merge
    into
        `steam_lakehouse`.`dbt_dev`.`dbt_source_freshness_results` as DBT_INTERNAL_DEST
    using
        `dbt_source_freshness_results__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
              DBT_INTERNAL_SOURCE.source_freshness_execution_id <=> DBT_INTERNAL_DEST.source_freshness_execution_id
          
    when matched
        then update set
            `source_freshness_execution_id` = DBT_INTERNAL_SOURCE.`source_freshness_execution_id`, `unique_id` = DBT_INTERNAL_SOURCE.`unique_id`, `max_loaded_at` = DBT_INTERNAL_SOURCE.`max_loaded_at`, `snapshotted_at` = DBT_INTERNAL_SOURCE.`snapshotted_at`, `generated_at` = DBT_INTERNAL_SOURCE.`generated_at`, `created_at` = DBT_INTERNAL_SOURCE.`created_at`, `max_loaded_at_time_ago_in_s` = DBT_INTERNAL_SOURCE.`max_loaded_at_time_ago_in_s`, `status` = DBT_INTERNAL_SOURCE.`status`, `error` = DBT_INTERNAL_SOURCE.`error`, `compile_started_at` = DBT_INTERNAL_SOURCE.`compile_started_at`, `compile_completed_at` = DBT_INTERNAL_SOURCE.`compile_completed_at`, `execute_started_at` = DBT_INTERNAL_SOURCE.`execute_started_at`, `execute_completed_at` = DBT_INTERNAL_SOURCE.`execute_completed_at`, `invocation_id` = DBT_INTERNAL_SOURCE.`invocation_id`, `warn_after` = DBT_INTERNAL_SOURCE.`warn_after`, `error_after` = DBT_INTERNAL_SOURCE.`error_after`, `filter` = DBT_INTERNAL_SOURCE.`filter`
    when not matched
        then insert
            (`source_freshness_execution_id`, `unique_id`, `max_loaded_at`, `snapshotted_at`, `generated_at`, `created_at`, `max_loaded_at_time_ago_in_s`, `status`, `error`, `compile_started_at`, `compile_completed_at`, `execute_started_at`, `execute_completed_at`, `invocation_id`, `warn_after`, `error_after`, `filter`) VALUES (DBT_INTERNAL_SOURCE.`source_freshness_execution_id`, DBT_INTERNAL_SOURCE.`unique_id`, DBT_INTERNAL_SOURCE.`max_loaded_at`, DBT_INTERNAL_SOURCE.`snapshotted_at`, DBT_INTERNAL_SOURCE.`generated_at`, DBT_INTERNAL_SOURCE.`created_at`, DBT_INTERNAL_SOURCE.`max_loaded_at_time_ago_in_s`, DBT_INTERNAL_SOURCE.`status`, DBT_INTERNAL_SOURCE.`error`, DBT_INTERNAL_SOURCE.`compile_started_at`, DBT_INTERNAL_SOURCE.`compile_completed_at`, DBT_INTERNAL_SOURCE.`execute_started_at`, DBT_INTERNAL_SOURCE.`execute_completed_at`, DBT_INTERNAL_SOURCE.`invocation_id`, DBT_INTERNAL_SOURCE.`warn_after`, DBT_INTERNAL_SOURCE.`error_after`, DBT_INTERNAL_SOURCE.`filter`)
