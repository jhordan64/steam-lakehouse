
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select player_count
from `steam_lakehouse`.`dbt_dev_silver`.`stg_steam__player_counts`
where player_count is null



  
  
      
    ) dbt_internal_test