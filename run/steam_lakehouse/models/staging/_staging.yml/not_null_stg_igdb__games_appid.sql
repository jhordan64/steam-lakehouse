
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select appid
from `steam_lakehouse`.`dbt_dev_silver`.`stg_igdb__games`
where appid is null



  
  
      
    ) dbt_internal_test