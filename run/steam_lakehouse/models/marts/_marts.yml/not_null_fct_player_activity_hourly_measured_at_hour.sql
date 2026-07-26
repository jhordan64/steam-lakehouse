
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select measured_at_hour
from `steam_lakehouse`.`dbt_dev_gold`.`fct_player_activity_hourly`
where measured_at_hour is null



  
  
      
    ) dbt_internal_test