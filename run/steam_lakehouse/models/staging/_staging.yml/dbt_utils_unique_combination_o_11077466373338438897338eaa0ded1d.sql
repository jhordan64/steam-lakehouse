
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        appid, measured_at_hour
    from `steam_lakehouse`.`dbt_dev_silver`.`stg_steam__player_counts`
    group by appid, measured_at_hour
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test