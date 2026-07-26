
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select appid
from `steam_lakehouse`.`bronze`.`steam_player_counts`
where appid is null



  
  
      
    ) dbt_internal_test