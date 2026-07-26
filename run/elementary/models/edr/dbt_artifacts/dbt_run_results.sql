-- back compat for old kwarg name
  
  
  
  
  
  
      
          
          
      
  

    merge
    into
        `steam_lakehouse`.`dbt_dev`.`dbt_run_results` as DBT_INTERNAL_DEST
    using
        `dbt_run_results__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
              DBT_INTERNAL_SOURCE.model_execution_id <=> DBT_INTERNAL_DEST.model_execution_id
          
    when matched
        then update set
            `model_execution_id` = DBT_INTERNAL_SOURCE.`model_execution_id`, `unique_id` = DBT_INTERNAL_SOURCE.`unique_id`, `invocation_id` = DBT_INTERNAL_SOURCE.`invocation_id`, `generated_at` = DBT_INTERNAL_SOURCE.`generated_at`, `created_at` = DBT_INTERNAL_SOURCE.`created_at`, `name` = DBT_INTERNAL_SOURCE.`name`, `message` = DBT_INTERNAL_SOURCE.`message`, `status` = DBT_INTERNAL_SOURCE.`status`, `resource_type` = DBT_INTERNAL_SOURCE.`resource_type`, `execution_time` = DBT_INTERNAL_SOURCE.`execution_time`, `execute_started_at` = DBT_INTERNAL_SOURCE.`execute_started_at`, `execute_completed_at` = DBT_INTERNAL_SOURCE.`execute_completed_at`, `compile_started_at` = DBT_INTERNAL_SOURCE.`compile_started_at`, `compile_completed_at` = DBT_INTERNAL_SOURCE.`compile_completed_at`, `rows_affected` = DBT_INTERNAL_SOURCE.`rows_affected`, `full_refresh` = DBT_INTERNAL_SOURCE.`full_refresh`, `compiled_code` = DBT_INTERNAL_SOURCE.`compiled_code`, `failures` = DBT_INTERNAL_SOURCE.`failures`, `query_id` = DBT_INTERNAL_SOURCE.`query_id`, `thread_id` = DBT_INTERNAL_SOURCE.`thread_id`, `materialization` = DBT_INTERNAL_SOURCE.`materialization`, `adapter_response` = DBT_INTERNAL_SOURCE.`adapter_response`
    when not matched
        then insert
            (`model_execution_id`, `unique_id`, `invocation_id`, `generated_at`, `created_at`, `name`, `message`, `status`, `resource_type`, `execution_time`, `execute_started_at`, `execute_completed_at`, `compile_started_at`, `compile_completed_at`, `rows_affected`, `full_refresh`, `compiled_code`, `failures`, `query_id`, `thread_id`, `materialization`, `adapter_response`) VALUES (DBT_INTERNAL_SOURCE.`model_execution_id`, DBT_INTERNAL_SOURCE.`unique_id`, DBT_INTERNAL_SOURCE.`invocation_id`, DBT_INTERNAL_SOURCE.`generated_at`, DBT_INTERNAL_SOURCE.`created_at`, DBT_INTERNAL_SOURCE.`name`, DBT_INTERNAL_SOURCE.`message`, DBT_INTERNAL_SOURCE.`status`, DBT_INTERNAL_SOURCE.`resource_type`, DBT_INTERNAL_SOURCE.`execution_time`, DBT_INTERNAL_SOURCE.`execute_started_at`, DBT_INTERNAL_SOURCE.`execute_completed_at`, DBT_INTERNAL_SOURCE.`compile_started_at`, DBT_INTERNAL_SOURCE.`compile_completed_at`, DBT_INTERNAL_SOURCE.`rows_affected`, DBT_INTERNAL_SOURCE.`full_refresh`, DBT_INTERNAL_SOURCE.`compiled_code`, DBT_INTERNAL_SOURCE.`failures`, DBT_INTERNAL_SOURCE.`query_id`, DBT_INTERNAL_SOURCE.`thread_id`, DBT_INTERNAL_SOURCE.`materialization`, DBT_INTERNAL_SOURCE.`adapter_response`)
