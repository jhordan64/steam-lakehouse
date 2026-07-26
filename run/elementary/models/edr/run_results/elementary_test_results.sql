-- back compat for old kwarg name
  
  
  
  
  
  
      
          
          
      
  

    merge
    into
        `steam_lakehouse`.`dbt_dev`.`elementary_test_results` as DBT_INTERNAL_DEST
    using
        `elementary_test_results__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
              DBT_INTERNAL_SOURCE.id <=> DBT_INTERNAL_DEST.id
          
    when matched
        then update set
            `id` = DBT_INTERNAL_SOURCE.`id`, `data_issue_id` = DBT_INTERNAL_SOURCE.`data_issue_id`, `test_execution_id` = DBT_INTERNAL_SOURCE.`test_execution_id`, `test_unique_id` = DBT_INTERNAL_SOURCE.`test_unique_id`, `model_unique_id` = DBT_INTERNAL_SOURCE.`model_unique_id`, `invocation_id` = DBT_INTERNAL_SOURCE.`invocation_id`, `detected_at` = DBT_INTERNAL_SOURCE.`detected_at`, `created_at` = DBT_INTERNAL_SOURCE.`created_at`, `database_name` = DBT_INTERNAL_SOURCE.`database_name`, `schema_name` = DBT_INTERNAL_SOURCE.`schema_name`, `table_name` = DBT_INTERNAL_SOURCE.`table_name`, `column_name` = DBT_INTERNAL_SOURCE.`column_name`, `test_type` = DBT_INTERNAL_SOURCE.`test_type`, `test_sub_type` = DBT_INTERNAL_SOURCE.`test_sub_type`, `test_results_description` = DBT_INTERNAL_SOURCE.`test_results_description`, `owners` = DBT_INTERNAL_SOURCE.`owners`, `tags` = DBT_INTERNAL_SOURCE.`tags`, `test_results_query` = DBT_INTERNAL_SOURCE.`test_results_query`, `other` = DBT_INTERNAL_SOURCE.`other`, `test_name` = DBT_INTERNAL_SOURCE.`test_name`, `test_params` = DBT_INTERNAL_SOURCE.`test_params`, `severity` = DBT_INTERNAL_SOURCE.`severity`, `status` = DBT_INTERNAL_SOURCE.`status`, `failures` = DBT_INTERNAL_SOURCE.`failures`, `test_short_name` = DBT_INTERNAL_SOURCE.`test_short_name`, `test_alias` = DBT_INTERNAL_SOURCE.`test_alias`, `result_rows` = DBT_INTERNAL_SOURCE.`result_rows`, `failed_row_count` = DBT_INTERNAL_SOURCE.`failed_row_count`
    when not matched
        then insert
            (`id`, `data_issue_id`, `test_execution_id`, `test_unique_id`, `model_unique_id`, `invocation_id`, `detected_at`, `created_at`, `database_name`, `schema_name`, `table_name`, `column_name`, `test_type`, `test_sub_type`, `test_results_description`, `owners`, `tags`, `test_results_query`, `other`, `test_name`, `test_params`, `severity`, `status`, `failures`, `test_short_name`, `test_alias`, `result_rows`, `failed_row_count`) VALUES (DBT_INTERNAL_SOURCE.`id`, DBT_INTERNAL_SOURCE.`data_issue_id`, DBT_INTERNAL_SOURCE.`test_execution_id`, DBT_INTERNAL_SOURCE.`test_unique_id`, DBT_INTERNAL_SOURCE.`model_unique_id`, DBT_INTERNAL_SOURCE.`invocation_id`, DBT_INTERNAL_SOURCE.`detected_at`, DBT_INTERNAL_SOURCE.`created_at`, DBT_INTERNAL_SOURCE.`database_name`, DBT_INTERNAL_SOURCE.`schema_name`, DBT_INTERNAL_SOURCE.`table_name`, DBT_INTERNAL_SOURCE.`column_name`, DBT_INTERNAL_SOURCE.`test_type`, DBT_INTERNAL_SOURCE.`test_sub_type`, DBT_INTERNAL_SOURCE.`test_results_description`, DBT_INTERNAL_SOURCE.`owners`, DBT_INTERNAL_SOURCE.`tags`, DBT_INTERNAL_SOURCE.`test_results_query`, DBT_INTERNAL_SOURCE.`other`, DBT_INTERNAL_SOURCE.`test_name`, DBT_INTERNAL_SOURCE.`test_params`, DBT_INTERNAL_SOURCE.`severity`, DBT_INTERNAL_SOURCE.`status`, DBT_INTERNAL_SOURCE.`failures`, DBT_INTERNAL_SOURCE.`test_short_name`, DBT_INTERNAL_SOURCE.`test_alias`, DBT_INTERNAL_SOURCE.`result_rows`, DBT_INTERNAL_SOURCE.`failed_row_count`)
