
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        game_key, measured_at_hour
    from `steam_lakehouse`.`dbt_dev_gold`.`fct_player_activity_hourly`
    group by game_key, measured_at_hour
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test