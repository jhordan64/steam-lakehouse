-- back compat for old kwarg name
  
  
  
  
  
  
      
          
          
      
  

    merge
    into
        `steam_lakehouse`.`dbt_dev`.`dbt_exposures` as DBT_INTERNAL_DEST
    using
        `dbt_exposures__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
              DBT_INTERNAL_SOURCE.unique_id <=> DBT_INTERNAL_DEST.unique_id
          
    when matched
        then update set
            `unique_id` = DBT_INTERNAL_SOURCE.`unique_id`, `name` = DBT_INTERNAL_SOURCE.`name`, `maturity` = DBT_INTERNAL_SOURCE.`maturity`, `type` = DBT_INTERNAL_SOURCE.`type`, `owner_email` = DBT_INTERNAL_SOURCE.`owner_email`, `owner_name` = DBT_INTERNAL_SOURCE.`owner_name`, `url` = DBT_INTERNAL_SOURCE.`url`, `depends_on_macros` = DBT_INTERNAL_SOURCE.`depends_on_macros`, `depends_on_nodes` = DBT_INTERNAL_SOURCE.`depends_on_nodes`, `depends_on_columns` = DBT_INTERNAL_SOURCE.`depends_on_columns`, `description` = DBT_INTERNAL_SOURCE.`description`, `tags` = DBT_INTERNAL_SOURCE.`tags`, `meta` = DBT_INTERNAL_SOURCE.`meta`, `package_name` = DBT_INTERNAL_SOURCE.`package_name`, `original_path` = DBT_INTERNAL_SOURCE.`original_path`, `path` = DBT_INTERNAL_SOURCE.`path`, `generated_at` = DBT_INTERNAL_SOURCE.`generated_at`, `metadata_hash` = DBT_INTERNAL_SOURCE.`metadata_hash`, `label` = DBT_INTERNAL_SOURCE.`label`, `raw_queries` = DBT_INTERNAL_SOURCE.`raw_queries`
    when not matched
        then insert
            (`unique_id`, `name`, `maturity`, `type`, `owner_email`, `owner_name`, `url`, `depends_on_macros`, `depends_on_nodes`, `depends_on_columns`, `description`, `tags`, `meta`, `package_name`, `original_path`, `path`, `generated_at`, `metadata_hash`, `label`, `raw_queries`) VALUES (DBT_INTERNAL_SOURCE.`unique_id`, DBT_INTERNAL_SOURCE.`name`, DBT_INTERNAL_SOURCE.`maturity`, DBT_INTERNAL_SOURCE.`type`, DBT_INTERNAL_SOURCE.`owner_email`, DBT_INTERNAL_SOURCE.`owner_name`, DBT_INTERNAL_SOURCE.`url`, DBT_INTERNAL_SOURCE.`depends_on_macros`, DBT_INTERNAL_SOURCE.`depends_on_nodes`, DBT_INTERNAL_SOURCE.`depends_on_columns`, DBT_INTERNAL_SOURCE.`description`, DBT_INTERNAL_SOURCE.`tags`, DBT_INTERNAL_SOURCE.`meta`, DBT_INTERNAL_SOURCE.`package_name`, DBT_INTERNAL_SOURCE.`original_path`, DBT_INTERNAL_SOURCE.`path`, DBT_INTERNAL_SOURCE.`generated_at`, DBT_INTERNAL_SOURCE.`metadata_hash`, DBT_INTERNAL_SOURCE.`label`, DBT_INTERNAL_SOURCE.`raw_queries`)
