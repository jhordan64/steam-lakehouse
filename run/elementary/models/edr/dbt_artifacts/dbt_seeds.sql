-- back compat for old kwarg name
  
  
  
  
  
  
      
          
          
      
  

    merge
    into
        `steam_lakehouse`.`dbt_dev`.`dbt_seeds` as DBT_INTERNAL_DEST
    using
        `dbt_seeds__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
              DBT_INTERNAL_SOURCE.unique_id <=> DBT_INTERNAL_DEST.unique_id
          
    when matched
        then update set
            `unique_id` = DBT_INTERNAL_SOURCE.`unique_id`, `alias` = DBT_INTERNAL_SOURCE.`alias`, `checksum` = DBT_INTERNAL_SOURCE.`checksum`, `tags` = DBT_INTERNAL_SOURCE.`tags`, `meta` = DBT_INTERNAL_SOURCE.`meta`, `owner` = DBT_INTERNAL_SOURCE.`owner`, `database_name` = DBT_INTERNAL_SOURCE.`database_name`, `schema_name` = DBT_INTERNAL_SOURCE.`schema_name`, `description` = DBT_INTERNAL_SOURCE.`description`, `name` = DBT_INTERNAL_SOURCE.`name`, `package_name` = DBT_INTERNAL_SOURCE.`package_name`, `original_path` = DBT_INTERNAL_SOURCE.`original_path`, `path` = DBT_INTERNAL_SOURCE.`path`, `generated_at` = DBT_INTERNAL_SOURCE.`generated_at`, `metadata_hash` = DBT_INTERNAL_SOURCE.`metadata_hash`
    when not matched
        then insert
            (`unique_id`, `alias`, `checksum`, `tags`, `meta`, `owner`, `database_name`, `schema_name`, `description`, `name`, `package_name`, `original_path`, `path`, `generated_at`, `metadata_hash`) VALUES (DBT_INTERNAL_SOURCE.`unique_id`, DBT_INTERNAL_SOURCE.`alias`, DBT_INTERNAL_SOURCE.`checksum`, DBT_INTERNAL_SOURCE.`tags`, DBT_INTERNAL_SOURCE.`meta`, DBT_INTERNAL_SOURCE.`owner`, DBT_INTERNAL_SOURCE.`database_name`, DBT_INTERNAL_SOURCE.`schema_name`, DBT_INTERNAL_SOURCE.`description`, DBT_INTERNAL_SOURCE.`name`, DBT_INTERNAL_SOURCE.`package_name`, DBT_INTERNAL_SOURCE.`original_path`, DBT_INTERNAL_SOURCE.`path`, DBT_INTERNAL_SOURCE.`generated_at`, DBT_INTERNAL_SOURCE.`metadata_hash`)
