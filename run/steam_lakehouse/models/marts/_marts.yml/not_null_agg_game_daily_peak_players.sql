
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select peak_players
from `steam_lakehouse`.`dbt_dev_gold`.`agg_game_daily`
where peak_players is null



  
  
      
    ) dbt_internal_test