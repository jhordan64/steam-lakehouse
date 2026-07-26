
    
    

with child as (
    select appid as from_field
    from `steam_lakehouse`.`dbt_dev_gold`.`dim_game`
    where appid is not null
),

parent as (
    select appid as to_field
    from `steam_lakehouse`.`dbt_dev_silver`.`stg_steam__apps`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


