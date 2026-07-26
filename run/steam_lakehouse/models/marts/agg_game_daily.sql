-- back compat for old kwarg name
  
  
  
  
  
  
      
          
              
              
          
              
              
          
      
  

    merge
    into
        `steam_lakehouse`.`dbt_dev_gold`.`agg_game_daily` as DBT_INTERNAL_DEST
    using
        `agg_game_daily__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
                  DBT_INTERNAL_SOURCE.game_key <=> DBT_INTERNAL_DEST.game_key
              
    and 
                  DBT_INTERNAL_SOURCE.measured_date <=> DBT_INTERNAL_DEST.measured_date
              
    when matched
        then update set
            *
    when not matched
        then insert
            *
