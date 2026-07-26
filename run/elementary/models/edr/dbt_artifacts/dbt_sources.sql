-- back compat for old kwarg name
  
  
  
  
  
  
      
          
          
      
  

    merge
    into
        `steam_lakehouse`.`dbt_dev`.`dbt_sources` as DBT_INTERNAL_DEST
    using
        `dbt_sources__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
              DBT_INTERNAL_SOURCE.unique_id <=> DBT_INTERNAL_DEST.unique_id
          
    when matched
        then update set
            `unique_id` = DBT_INTERNAL_SOURCE.`unique_id`, `database_name` = DBT_INTERNAL_SOURCE.`database_name`, `schema_name` = DBT_INTERNAL_SOURCE.`schema_name`, `source_name` = DBT_INTERNAL_SOURCE.`source_name`, `name` = DBT_INTERNAL_SOURCE.`name`, `identifier` = DBT_INTERNAL_SOURCE.`identifier`, `loaded_at_field` = DBT_INTERNAL_SOURCE.`loaded_at_field`, `freshness_warn_after` = DBT_INTERNAL_SOURCE.`freshness_warn_after`, `freshness_error_after` = DBT_INTERNAL_SOURCE.`freshness_error_after`, `freshness_filter` = DBT_INTERNAL_SOURCE.`freshness_filter`, `freshness_description` = DBT_INTERNAL_SOURCE.`freshness_description`, `relation_name` = DBT_INTERNAL_SOURCE.`relation_name`, `tags` = DBT_INTERNAL_SOURCE.`tags`, `meta` = DBT_INTERNAL_SOURCE.`meta`, `owner` = DBT_INTERNAL_SOURCE.`owner`, `package_name` = DBT_INTERNAL_SOURCE.`package_name`, `original_path` = DBT_INTERNAL_SOURCE.`original_path`, `path` = DBT_INTERNAL_SOURCE.`path`, `source_description` = DBT_INTERNAL_SOURCE.`source_description`, `description` = DBT_INTERNAL_SOURCE.`description`, `generated_at` = DBT_INTERNAL_SOURCE.`generated_at`, `metadata_hash` = DBT_INTERNAL_SOURCE.`metadata_hash`
    when not matched
        then insert
            (`unique_id`, `database_name`, `schema_name`, `source_name`, `name`, `identifier`, `loaded_at_field`, `freshness_warn_after`, `freshness_error_after`, `freshness_filter`, `freshness_description`, `relation_name`, `tags`, `meta`, `owner`, `package_name`, `original_path`, `path`, `source_description`, `description`, `generated_at`, `metadata_hash`) VALUES (DBT_INTERNAL_SOURCE.`unique_id`, DBT_INTERNAL_SOURCE.`database_name`, DBT_INTERNAL_SOURCE.`schema_name`, DBT_INTERNAL_SOURCE.`source_name`, DBT_INTERNAL_SOURCE.`name`, DBT_INTERNAL_SOURCE.`identifier`, DBT_INTERNAL_SOURCE.`loaded_at_field`, DBT_INTERNAL_SOURCE.`freshness_warn_after`, DBT_INTERNAL_SOURCE.`freshness_error_after`, DBT_INTERNAL_SOURCE.`freshness_filter`, DBT_INTERNAL_SOURCE.`freshness_description`, DBT_INTERNAL_SOURCE.`relation_name`, DBT_INTERNAL_SOURCE.`tags`, DBT_INTERNAL_SOURCE.`meta`, DBT_INTERNAL_SOURCE.`owner`, DBT_INTERNAL_SOURCE.`package_name`, DBT_INTERNAL_SOURCE.`original_path`, DBT_INTERNAL_SOURCE.`path`, DBT_INTERNAL_SOURCE.`source_description`, DBT_INTERNAL_SOURCE.`description`, DBT_INTERNAL_SOURCE.`generated_at`, DBT_INTERNAL_SOURCE.`metadata_hash`)
