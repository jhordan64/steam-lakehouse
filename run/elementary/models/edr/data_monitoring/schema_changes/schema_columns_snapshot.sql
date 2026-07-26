-- back compat for old kwarg name
  
  
  
  
  
  
      
          
          
      
  

    merge
    into
        `steam_lakehouse`.`dbt_dev`.`schema_columns_snapshot` as DBT_INTERNAL_DEST
    using
        `schema_columns_snapshot__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
              DBT_INTERNAL_SOURCE.column_state_id <=> DBT_INTERNAL_DEST.column_state_id
          
    when matched
        then update set
            `column_state_id` = DBT_INTERNAL_SOURCE.`column_state_id`, `full_column_name` = DBT_INTERNAL_SOURCE.`full_column_name`, `full_table_name` = DBT_INTERNAL_SOURCE.`full_table_name`, `column_name` = DBT_INTERNAL_SOURCE.`column_name`, `data_type` = DBT_INTERNAL_SOURCE.`data_type`, `is_new` = DBT_INTERNAL_SOURCE.`is_new`, `detected_at` = DBT_INTERNAL_SOURCE.`detected_at`, `created_at` = DBT_INTERNAL_SOURCE.`created_at`
    when not matched
        then insert
            (`column_state_id`, `full_column_name`, `full_table_name`, `column_name`, `data_type`, `is_new`, `detected_at`, `created_at`) VALUES (DBT_INTERNAL_SOURCE.`column_state_id`, DBT_INTERNAL_SOURCE.`full_column_name`, DBT_INTERNAL_SOURCE.`full_table_name`, DBT_INTERNAL_SOURCE.`column_name`, DBT_INTERNAL_SOURCE.`data_type`, DBT_INTERNAL_SOURCE.`is_new`, DBT_INTERNAL_SOURCE.`detected_at`, DBT_INTERNAL_SOURCE.`created_at`)
