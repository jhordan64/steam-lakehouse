
    
    

select
    appid as unique_field,
    count(*) as n_records

from `steam_lakehouse`.`dbt_dev_gold`.`dim_game`
where appid is not null
group by appid
having count(*) > 1


