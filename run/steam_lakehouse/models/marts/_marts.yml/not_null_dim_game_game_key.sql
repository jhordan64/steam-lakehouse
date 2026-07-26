
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select game_key
from `steam_lakehouse`.`dbt_dev_gold`.`dim_game`
where game_key is null



  
  
      
    ) dbt_internal_test