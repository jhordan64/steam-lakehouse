
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select player_count
from `steam_lakehouse`.`dbt_dev_gold`.`fct_player_activity_hourly`
where player_count is null



  
  
      
    ) dbt_internal_test