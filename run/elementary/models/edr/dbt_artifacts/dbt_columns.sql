-- back compat for old kwarg name
  
  
  
  
  
  
      
          
          
      
  

    merge
    into
        `steam_lakehouse`.`dbt_dev`.`dbt_columns` as DBT_INTERNAL_DEST
    using
        `dbt_columns__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
              DBT_INTERNAL_SOURCE.unique_id <=> DBT_INTERNAL_DEST.unique_id
          
    when matched
        then update set
            `unique_id` = DBT_INTERNAL_SOURCE.`unique_id`, `parent_unique_id` = DBT_INTERNAL_SOURCE.`parent_unique_id`, `name` = DBT_INTERNAL_SOURCE.`name`, `data_type` = DBT_INTERNAL_SOURCE.`data_type`, `tags` = DBT_INTERNAL_SOURCE.`tags`, `meta` = DBT_INTERNAL_SOURCE.`meta`, `database_name` = DBT_INTERNAL_SOURCE.`database_name`, `schema_name` = DBT_INTERNAL_SOURCE.`schema_name`, `table_name` = DBT_INTERNAL_SOURCE.`table_name`, `description` = DBT_INTERNAL_SOURCE.`description`, `resource_type` = DBT_INTERNAL_SOURCE.`resource_type`, `generated_at` = DBT_INTERNAL_SOURCE.`generated_at`, `metadata_hash` = DBT_INTERNAL_SOURCE.`metadata_hash`
    when not matched
        then insert
            (`unique_id`, `parent_unique_id`, `name`, `data_type`, `tags`, `meta`, `database_name`, `schema_name`, `table_name`, `description`, `resource_type`, `generated_at`, `metadata_hash`) VALUES (DBT_INTERNAL_SOURCE.`unique_id`, DBT_INTERNAL_SOURCE.`parent_unique_id`, DBT_INTERNAL_SOURCE.`name`, DBT_INTERNAL_SOURCE.`data_type`, DBT_INTERNAL_SOURCE.`tags`, DBT_INTERNAL_SOURCE.`meta`, DBT_INTERNAL_SOURCE.`database_name`, DBT_INTERNAL_SOURCE.`schema_name`, DBT_INTERNAL_SOURCE.`table_name`, DBT_INTERNAL_SOURCE.`description`, DBT_INTERNAL_SOURCE.`resource_type`, DBT_INTERNAL_SOURCE.`generated_at`, DBT_INTERNAL_SOURCE.`metadata_hash`)
