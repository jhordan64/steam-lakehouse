-- back compat for old kwarg name
  
  
  
  
  
  
      
          
              
              
          
              
              
          
      
  

    merge
    into
        `steam_lakehouse`.`dbt_dev_gold`.`fct_player_activity_hourly` as DBT_INTERNAL_DEST
    using
        `fct_player_activity_hourly__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        
                  DBT_INTERNAL_SOURCE.game_key <=> DBT_INTERNAL_DEST.game_key
              
    and 
                  DBT_INTERNAL_SOURCE.measured_at_hour <=> DBT_INTERNAL_DEST.measured_at_hour
              
    when matched
        then update set
            `game_key` = DBT_INTERNAL_SOURCE.`game_key`, `appid` = DBT_INTERNAL_SOURCE.`appid`, `measured_at_hour` = DBT_INTERNAL_SOURCE.`measured_at_hour`, `measured_date` = DBT_INTERNAL_SOURCE.`measured_date`, `hour_of_day` = DBT_INTERNAL_SOURCE.`hour_of_day`, `day_of_week` = DBT_INTERNAL_SOURCE.`day_of_week`, `player_count` = DBT_INTERNAL_SOURCE.`player_count`, `player_count_prev_hour` = DBT_INTERNAL_SOURCE.`player_count_prev_hour`, `player_delta_hour` = DBT_INTERNAL_SOURCE.`player_delta_hour`, `player_count_ma_24h` = DBT_INTERNAL_SOURCE.`player_count_ma_24h`, `player_growth_pct_hour` = DBT_INTERNAL_SOURCE.`player_growth_pct_hour`
    when not matched
        then insert
            (`game_key`, `appid`, `measured_at_hour`, `measured_date`, `hour_of_day`, `day_of_week`, `player_count`, `player_count_prev_hour`, `player_delta_hour`, `player_count_ma_24h`, `player_growth_pct_hour`) VALUES (DBT_INTERNAL_SOURCE.`game_key`, DBT_INTERNAL_SOURCE.`appid`, DBT_INTERNAL_SOURCE.`measured_at_hour`, DBT_INTERNAL_SOURCE.`measured_date`, DBT_INTERNAL_SOURCE.`hour_of_day`, DBT_INTERNAL_SOURCE.`day_of_week`, DBT_INTERNAL_SOURCE.`player_count`, DBT_INTERNAL_SOURCE.`player_count_prev_hour`, DBT_INTERNAL_SOURCE.`player_delta_hour`, DBT_INTERNAL_SOURCE.`player_count_ma_24h`, DBT_INTERNAL_SOURCE.`player_growth_pct_hour`)
