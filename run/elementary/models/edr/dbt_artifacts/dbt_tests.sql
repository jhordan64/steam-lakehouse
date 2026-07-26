-- back compat for old kwarg name
  
  
  
  
  
  
      
          
          
      
  

    merge
    into
        `steam_lakehouse`.`dbt_dev`.`dbt_tests` as DBT_INTERNAL_DEST
    using
        `dbt_tests__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
              DBT_INTERNAL_SOURCE.unique_id <=> DBT_INTERNAL_DEST.unique_id
          
    when matched
        then update set
            `unique_id` = DBT_INTERNAL_SOURCE.`unique_id`, `database_name` = DBT_INTERNAL_SOURCE.`database_name`, `schema_name` = DBT_INTERNAL_SOURCE.`schema_name`, `name` = DBT_INTERNAL_SOURCE.`name`, `short_name` = DBT_INTERNAL_SOURCE.`short_name`, `alias` = DBT_INTERNAL_SOURCE.`alias`, `test_column_name` = DBT_INTERNAL_SOURCE.`test_column_name`, `severity` = DBT_INTERNAL_SOURCE.`severity`, `warn_if` = DBT_INTERNAL_SOURCE.`warn_if`, `error_if` = DBT_INTERNAL_SOURCE.`error_if`, `test_params` = DBT_INTERNAL_SOURCE.`test_params`, `test_namespace` = DBT_INTERNAL_SOURCE.`test_namespace`, `test_original_name` = DBT_INTERNAL_SOURCE.`test_original_name`, `tags` = DBT_INTERNAL_SOURCE.`tags`, `model_tags` = DBT_INTERNAL_SOURCE.`model_tags`, `model_owners` = DBT_INTERNAL_SOURCE.`model_owners`, `meta` = DBT_INTERNAL_SOURCE.`meta`, `depends_on_macros` = DBT_INTERNAL_SOURCE.`depends_on_macros`, `depends_on_nodes` = DBT_INTERNAL_SOURCE.`depends_on_nodes`, `parent_model_unique_id` = DBT_INTERNAL_SOURCE.`parent_model_unique_id`, `description` = DBT_INTERNAL_SOURCE.`description`, `package_name` = DBT_INTERNAL_SOURCE.`package_name`, `type` = DBT_INTERNAL_SOURCE.`type`, `original_path` = DBT_INTERNAL_SOURCE.`original_path`, `path` = DBT_INTERNAL_SOURCE.`path`, `generated_at` = DBT_INTERNAL_SOURCE.`generated_at`, `metadata_hash` = DBT_INTERNAL_SOURCE.`metadata_hash`, `quality_dimension` = DBT_INTERNAL_SOURCE.`quality_dimension`
    when not matched
        then insert
            (`unique_id`, `database_name`, `schema_name`, `name`, `short_name`, `alias`, `test_column_name`, `severity`, `warn_if`, `error_if`, `test_params`, `test_namespace`, `test_original_name`, `tags`, `model_tags`, `model_owners`, `meta`, `depends_on_macros`, `depends_on_nodes`, `parent_model_unique_id`, `description`, `package_name`, `type`, `original_path`, `path`, `generated_at`, `metadata_hash`, `quality_dimension`) VALUES (DBT_INTERNAL_SOURCE.`unique_id`, DBT_INTERNAL_SOURCE.`database_name`, DBT_INTERNAL_SOURCE.`schema_name`, DBT_INTERNAL_SOURCE.`name`, DBT_INTERNAL_SOURCE.`short_name`, DBT_INTERNAL_SOURCE.`alias`, DBT_INTERNAL_SOURCE.`test_column_name`, DBT_INTERNAL_SOURCE.`severity`, DBT_INTERNAL_SOURCE.`warn_if`, DBT_INTERNAL_SOURCE.`error_if`, DBT_INTERNAL_SOURCE.`test_params`, DBT_INTERNAL_SOURCE.`test_namespace`, DBT_INTERNAL_SOURCE.`test_original_name`, DBT_INTERNAL_SOURCE.`tags`, DBT_INTERNAL_SOURCE.`model_tags`, DBT_INTERNAL_SOURCE.`model_owners`, DBT_INTERNAL_SOURCE.`meta`, DBT_INTERNAL_SOURCE.`depends_on_macros`, DBT_INTERNAL_SOURCE.`depends_on_nodes`, DBT_INTERNAL_SOURCE.`parent_model_unique_id`, DBT_INTERNAL_SOURCE.`description`, DBT_INTERNAL_SOURCE.`package_name`, DBT_INTERNAL_SOURCE.`type`, DBT_INTERNAL_SOURCE.`original_path`, DBT_INTERNAL_SOURCE.`path`, DBT_INTERNAL_SOURCE.`generated_at`, DBT_INTERNAL_SOURCE.`metadata_hash`, DBT_INTERNAL_SOURCE.`quality_dimension`)
