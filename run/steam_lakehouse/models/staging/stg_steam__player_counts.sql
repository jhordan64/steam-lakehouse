-- back compat for old kwarg name
  
  
  
  
  
  
      
          
              
              
          
              
              
          
      
  

    merge
    into
        `steam_lakehouse`.`dbt_dev_silver`.`stg_steam__player_counts` as DBT_INTERNAL_DEST
    using
        `stg_steam__player_counts__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
                  DBT_INTERNAL_SOURCE.appid <=> DBT_INTERNAL_DEST.appid
              
    and 
                  DBT_INTERNAL_SOURCE.measured_at_hour <=> DBT_INTERNAL_DEST.measured_at_hour
              
    when matched
        then update set
            `appid` = DBT_INTERNAL_SOURCE.`appid`, `player_count` = DBT_INTERNAL_SOURCE.`player_count`, `api_result_code` = DBT_INTERNAL_SOURCE.`api_result_code`, `measured_at` = DBT_INTERNAL_SOURCE.`measured_at`, `measured_at_hour` = DBT_INTERNAL_SOURCE.`measured_at_hour`, `measured_date` = DBT_INTERNAL_SOURCE.`measured_date`, `_source_file` = DBT_INTERNAL_SOURCE.`_source_file`, `_loaded_at` = DBT_INTERNAL_SOURCE.`_loaded_at`
    when not matched
        then insert
            (`appid`, `player_count`, `api_result_code`, `measured_at`, `measured_at_hour`, `measured_date`, `_source_file`, `_loaded_at`) VALUES (DBT_INTERNAL_SOURCE.`appid`, DBT_INTERNAL_SOURCE.`player_count`, DBT_INTERNAL_SOURCE.`api_result_code`, DBT_INTERNAL_SOURCE.`measured_at`, DBT_INTERNAL_SOURCE.`measured_at_hour`, DBT_INTERNAL_SOURCE.`measured_date`, DBT_INTERNAL_SOURCE.`_source_file`, DBT_INTERNAL_SOURCE.`_loaded_at`)
