
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    appid as unique_field,
    count(*) as n_records

from `steam_lakehouse`.`dbt_dev_silver`.`stg_igdb__games`
where appid is not null
group by appid
having count(*) > 1



  
  
      
    ) dbt_internal_test