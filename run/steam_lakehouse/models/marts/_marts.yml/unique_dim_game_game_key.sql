
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    game_key as unique_field,
    count(*) as n_records

from `steam_lakehouse`.`dbt_dev_gold`.`dim_game`
where game_key is not null
group by game_key
having count(*) > 1



  
  
      
    ) dbt_internal_test