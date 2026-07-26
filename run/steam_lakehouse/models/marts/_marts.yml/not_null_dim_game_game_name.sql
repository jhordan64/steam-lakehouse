
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select game_name
from `steam_lakehouse`.`dbt_dev_gold`.`dim_game`
where game_name is null



  
  
      
    ) dbt_internal_test